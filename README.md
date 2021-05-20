# Elixir API server

## 함수형 프로그래밍으로 API 서버 만들기

### 전자결재 서버 만들기

#### 기능
- 문서를 기안한다.  
- 문서를 승인/반려/보류 한다.  
- 문서가 승인/반려 되면 기안자와 결재자들에게 알람이 발송 된다.  

#### 테이블

##### document (문서)
|column|type|description|
|------|----|-----------|
|id|integer|문서 id|
|title|string|제목|
|content|string|내용|
|drafter_id|integer|기안자 id|
|drafter_opinion|string|기안자 의견|
|created_at|datetime|생성 시간|

##### approve_lines (결재선)
|column|type|description|
|------|----|-----------|
|id|integer|결재선 id|
|sequence|integer|순서|
|approver_id|integer|결재자 id|
|approve_type|enum|결재 종류 (APPROVE, REJECT, PENDING)|
|opinion|string|결재 의견|
|acted_at|datetime|결제 시간|


## spec
- elixir
- phoenix framework

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
CREATE DATABASE blog_dev;
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
