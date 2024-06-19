# AdVoyager(애드보이저)

# 🛫 프로젝트 소개

> 🤦‍♂️ 이번 여행에서 자세한 여행 코스를 누가 대신 짜 줬으면…
🤔 국내 여행지를 돌아보고 싶은데 좋은 코스 없을까?
> 

Step-by-Step 여행 계획으로, 다른 사람에게 자신의 여행 코스를 공유하거나,

여행 전부터 코스를 고민하지 않아도 코스를 공유받아 고민 없이 편하게 여행을 다닐 수 있는 앱

# 🛠️ 기술 스택과 개발환경

- 언어: Swift
- IDE: XCode
- Front-End: UIKit
- DB : Realm
- 그 외 OpenSources: SnapKit, Kingfisher, RxSwift, Toast, RxGesture, Alamofire, Tabman, FSCalendar, IQKeyboardManagerSwift, Hero

# ⚠️ 트러블 슈팅

## 1. String 타입으로 제한된 Content 필드 활용하기

- 여행 일정 데이터는 크게 2가지로, [여행 계획, 계획 내 세부 일정(List)] 으로 이루어짐
- 이것을 서버에 `json` 형태로 올리려고 보니, `content` 필드는 `String` 타입으로만 제한됨
- 그래서 이것을 해결하기 위해 `Realm Object` → `Codable Struct` → `json` → `String` 형태로 변환하여 업로드하고, 다시 서버에서 다운로드할 때 `String` → `json` → `Codable Struct` → `Realm Object` 로 변환할 수 있는 기능을 만들었다

### 1) Codable 한 `struct` 로 변환

```swift
final class TravelPlan: Object, Identifiable {
    
    // 모델 정보...
    
    func convertToCodableModel() -> TravelPlanModel {
        return TravelPlanModel(id: "", planTitle: self.planTitle, firstDate: self.firstDate, lastDate: self.lastDate)
    }
}
```

### 2) `Encodable` 을 확장하여 `String` 으로 인코딩할 수 있는 기능 추가

```swift
extension Encodable {
    func encode<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(value)
    }
    
    func encodeToString() -> String {
        do {
            let data = try encode(self)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            print("인코딩 에러가 발생했습니다. : \(error)")
            return ""
        }
    }
}
```

### 3) 서버에서 받을 때 `saveTravelPlan()` 메서드를 만들어 받기

```swift
func saveTravelPlan(post: Post?, pushBackedDate: Date?) -> Bool {
        
        // 생략 ...
        
        let rawTravelPlanString = post.content1
        let rawTravelScheduleStrings = post.content2?.split(separator: "`")
        
        // 중략 ...
        
        repository.addTravelPlan(travelPlan)
        
        travelScheduleModels.forEach {
            repository.addSchedule(...)
        }
        
        return true
    }
```

- 여행 스케쥴의 경우 배열 형태로 이루어져 있어, 서버에 올릴때 하나의 `String` 으로 `.joined()` 하여 올렸으므로, 받을 땐 `split` 을 통해 나눠주는 과정을 추가했다

## 2. PHPicker를 통한 다중 이미지 추가에서 발생할 수 있었던 
     미니 DDOS 어택

- PHPicker는 다중 선택한 이미지를 가져올 때 꼭 선택한 순서대로 가져와지는것은 아니라는 것을 개발 도중에 확인
- 알고보니 `.loadObject()` 가 비동기 처리되는 것을 알았음
- 원하는 동작 방식은 모든 이미지가 로드된 후 → 서버에 전송하는 그림이었으나,
이미지 로드 → 서버 전송 → 또 다음 이미지 로드 → 전송 … 이러한 과정이 되어버릴 수 있는 상황
- 때마침 모 개발 단톡방에서 이런 메세지를 봐서 `뜨끔` 하는 바람에 개선을 해야겠다고 생각

![image](https://github.com/crisine/AdVoyager/assets/16317758/0451d534-09fe-425b-b32d-8ad7c87072ef)

```swift
func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        let group = DispatchGroup()
        
        // 대략 이미지 순환하는 루프 ...
                    
                    if let image = image as? UIImage {
                        DispatchQueue.global().async {
                            print("이미지 스트림으로 이미지 전송")
                            self?.imageStream.onNext(image)
                        }
                    }
                    
        // 루프 종료 부분 ...
        
        group.notify(queue: .global()) {
            group.wait()
            self.finishedAddingImageTrigger.onNext(())
        }
        
        picker.dismiss(animated: true)
    }
```

- 이미지 스트림이라고 만들어 둔 `PublishSubject` 를 통해 `viewModel` 로 이미지를 한개씩 전송
- 루프가 종료되기 전까지 각 이미지 추가 과정은 글로벌 디스패치 그룹에 속함
- 모든 이미지 추가가 종료되고 그룹에서 떠난 경우, `finishedAddingImageTrigger` 를 통해 서버와의 통신은 단 한번만 하도록 진행

# 📱 주요 기능과 스크린샷

 

## 로그인 & 회원 가입

<table>
  <tr>
  <td> 
    <img src="https://github.com/crisine/AdVoyager/assets/16317758/a3f7cca0-7bfa-47ac-aa10-78efe1560966">
  </td>
  <td> 
    <img src="https://github.com/crisine/AdVoyager/assets/16317758/31101ecb-4376-43eb-8802-82aefcb1de51">
  </td>
</tr>
</table>





## 메인 화면 & 검색 화면

<table>
  <tr>
    <td>
      <img src="https://github.com/crisine/AdVoyager/assets/16317758/ab8596df-4e00-4173-9a0f-fdef21d2906e">
    </td>
    <td>
      <img src="https://github.com/crisine/AdVoyager/assets/16317758/43a68a83-283e-4403-9576-e5bb99e68775">
    </td>
  </tr>
</table>



## 포스트 상세 조회 화면 & 댓글 화면

<table>
  <tr>
    <td>
      <img src="https://github.com/crisine/AdVoyager/assets/16317758/28e25978-e86f-4d44-bb04-0c6ac94659b8">
    </td>
    <td>
      <img src="https://github.com/crisine/AdVoyager/assets/16317758/0301e177-ec64-4d01-bc66-7ab9de686938">
    </td>
  </tr>
</table>


## 여행 계획 오버뷰 & 여행 계획 추가 화면

<table>
  <tr>
    <td>
      <img src="https://github.com/crisine/AdVoyager/assets/16317758/822004e2-a3b0-4ba4-94b7-14a7e103b5a3">
    </td>
    <td>
      <img src="https://github.com/crisine/AdVoyager/assets/16317758/65495c6f-ad3c-4ed5-9c62-e2417db21d25">
    </td>
  </tr>
</table>


## 상세 여행 스케줄 조회 & 여행 스케줄 추가 화면

<table>
  <tr>
    <td>
      <img src="https://github.com/crisine/AdVoyager/assets/16317758/802f1dfe-1990-4b08-a58a-c040566b0083">
    </td>
    <td>
      <img src="https://github.com/crisine/AdVoyager/assets/16317758/38aa38d5-bdbe-4f6b-825a-94498ffb45ea">
    </td>
  </tr>
</table>


## 프로필 & 프로필 수정 화면

<table>
  <tr>
    <td>
      <img src="https://github.com/crisine/AdVoyager/assets/16317758/661abd8d-6098-49b6-b50c-0e51679b56a9">
    </td>
    <td>
      <img src="https://github.com/crisine/AdVoyager/assets/16317758/0dadb1b7-c1cb-46a7-99f7-dca52605d850">
    </td>
  </tr>
</table>
