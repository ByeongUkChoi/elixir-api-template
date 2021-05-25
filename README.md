# Elixir API server

## 함수형 프로그래밍으로 전자결재 API 서버 만들기

### 기능
- 문서를 기안한다.  
- 결재자는 자신의 차례에 문서를 승인/반려/보류 할 수 있다.  
- 문서가 보류 상태이면 다음 결재자로 넘어가지 않는다. 해당 결재자가 승인/반려를 할 수 있다.
- 문서가 승인/반려 되면 기안자와 결재자들에게 알람이 발송 된다.  

### 테이블

#### document (문서)
|column|type|description|
|------|----|-----------|
|id|integer|문서 id|
|title|string|제목|
|content|string|내용|
|drafter_id|integer|기안자 id|
|drafter_opinion|string|기안자 의견|
|created_at|datetime|생성 시간|

#### approval_lines (결재선)
|column|type|description|
|------|----|-----------|
|id|integer|결재선 id|
|sequence|integer|순서|
|approver_id|integer|결재자 id|
|approve_type|enum|결재 종류 (APPROVE, REJECT, PENDING)|
|opinion|string|결재 의견|
|received_at|datetime|수신 시간|
|acted_at|datetime|결재 시간|
|document_id|integer|문서 id|

##### generate
```
mix phx.gen.json Documents Document documents title:string content:string drafter_id:integer drafter_opinion:string
mix phx.gen.context ApprovalLines ApprovalLine approval_lines sequence:integer approver_id:integer approval_type:string opinion:string received_at:datetime acted_at:datetime document_id:references:documents

mix ecto.migrate
```
##### insert dummy data
```
INSERT INTO documents (title, content, drafter_id, drafter_opinion, inserted_at, updated_at) VALUES ('report', 'this is content', 1, 'hello', NOW(), NOW());

INSERT INTO 
  approval_lines (sequence ,approver_id ,approval_type ,opinion ,received_at ,acted_at ,document_id ,inserted_at, updated_at)
VALUES 
  (1, 2, NULL, '', NOW(), NULL, 1, NOW(), NOW()),
  (2, 3, NULL, '', NULL, NULL, 1, NOW(), NOW());
```

### API document

#### 문서 목록 조회하기
##### Request
```http request
GET /api/documents HTTP/1.1
```
##### Response
```http request
HTTP/1.1 200 OK
Content-Type: application/json;charset=UTF-8
"data": [
  {
    "id": 1,
    "title": "Leave application",
    "content": "I want to leave..",
    "drafterId": 1,
    "drafterOpinion": "help",
    "createdAt": "2021-05-22 12:00:00",
    "approvalLines": [
      {
        "sequence": 1,
        "approverId": 2,
        "approvalType": "APPROVE",
        "opinion": "go",
        "receivedAt": "2021-05-22 12:00:00",
        "actedAt": "2021-05-22 13:10:00"
      },
      {
        "sequence": 2,
        "approverId": 3,
        "receivedAt": "2021-05-22 13:10:00",
      },
    ]
  }
]
```

#### 문서 상세 조회하기
##### Request
```http request
GET /api/documents/{documentId} HTTP/1.1
```
##### Response
```http request
HTTP/1.1 200 OK
Content-Type: application/json;charset=UTF-8
{
  "id": 1,
  "title": "Leave application"
  "content": "I want to leave.."
  "drafterId": 1,
  "drafterOpinion": "help",
  "createdAt": "2021-05-22 12:00:00",
  "approveLines" : [
    {
      "sequence": 1,
      "approverId": 2,
      "approveType": "APPROVE",
      "opinion": "go",
      "receivedAt": "2021-05-22 12:00:00",
      "actedAt": "2021-05-22 13:10:00"
    },
    {
      "sequence": 2,
      "approverId": 3,
      "receivedAt": "2021-05-22 13:10:00",
    },
  ]
}
```

#### 문서 상신하기
##### Request
```http request
POST /api/documents HTTP/1.1
Content-type: application/json;charset=utf-8
```
#### Response
```http request
HTTP/1.1 201 Created
```

#### 문서 결재하기
##### Request
```http request
PUT /api/documents/{documentId}/{approveType} HTTP/1.1
Content-type: application/json;charset=utf-8
```
#### Response
```http request
HTTP/1.1 200 OK
```


### spec
- elixir
- phoenix framework

## debugging (with VSCode)
1. install  plugin : ElixirLS: Elixir support and debugger
2. set configuration
Add task 
```
{
    "configurations": [
        {
            "type": "mix_task",
            "name": "mix (Default task)",
            "request": "launch",
            "task": "phx.server",   // <!-- here -->
            "projectDir": "${workspaceRoot}"
        },
    ]
}
```
3. starting debug (F5)
4. http request

## run
### application (development)
```
iex -S mix phx.server
```
### database
```
docker run -p 5432:5432 --name postgres -e POSTGRES_PASSWORD=postgres -d postgres
docker exec -it postgres
psql -U postgres
CREATE DATABASE approval_dev;
```

---
## Elixir Project
### install elixir for mac
```
brew install elixir
```
### create project
```
mix new example
```
### complie project
```
mix compile
```
### run project (interactive mode in iex)
```
iex -S mix
```
#### check & call function
```
iex > Application.loaded_applications
iex > ElixirExampleProject.hello
```
### recompile in iex
```
iex > recomple
```
### run project
```
mix run
```

---

## Phoenix framework Project

### install phoenix
```
mix archive.install hex phx_new
```
### create elixir project (useful for APIs)
```
mix phx.new demo --no-html --no-webpack
```
### run (development)
```
iex -S mix phx.server
```
### generate json resource
```
mix phx.gen.json Posts Post posts title:string content:string authorId:integer createdAt:datetime
```
### generate context
```
mix phx.gen.context Comments Comment comments name:string content:text post_id:references:posts
```


---

# Approval

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
