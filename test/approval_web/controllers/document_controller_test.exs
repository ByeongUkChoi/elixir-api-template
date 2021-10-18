defmodule ApprovalWeb.DocumentControllerTest do
  use ApprovalWeb.ConnCase

  import Ecto.Changeset

  alias Approval.Repo
  alias Approval.Documents.Document

  @valid_attrs %{
    title: "some title",
    content: "some content",
    drafter_id: 42,
    drafter_opinion: "some drafter_opinion",
    status: :ON_PROGRESS,
    inserted_at: ~N[2000-01-01 23:00:07],
    updated_at: ~N[2000-01-01 23:00:07],
    approval_lines: [%{sequence: 1, approver_id: 11, received_at: ~N[2000-01-01 23:00:07]}]
  }

  def document_fixture(attrs \\ %{}) do
    {:ok, document} =
      %Document{}
      |> change(Enum.into(attrs, @valid_attrs))
      |> Repo.insert()

    document
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all documents", %{conn: conn} do
      # given
      %{id: document_id} = document_fixture()

      # when
      conn = get(conn, Routes.document_path(conn, :index))

      # then
      assert json_response(conn, 200)["data"] |> length == 1
      assert [%{"id" => ^document_id}] = json_response(conn, 200)["data"]

      assert %{"page" => 1, "per_page" => 10, "total_count" => 1} ==
               json_response(conn, 200)["pageable"]
    end
  end

  describe "show" do
    test "show document", %{conn: conn} do
      # given
      %{id: document_id} = document_fixture()

      # when
      conn = get(conn, Routes.document_path(conn, :show, document_id))

      # then
      assert %{"id" => ^document_id} = json_response(conn, 200)
    end

    test "not found document", %{conn: conn} do
      conn = get(conn, Routes.document_path(conn, :show, -1))
      assert json_response(conn, 404)["errors"]["detail"] == "Not Found"
    end
  end

  describe "draft" do
    test "draft document", %{conn: conn} do
      # given
      drafter_id = 42
      approver_id = 11

      params = %{
        "title" => "some title",
        "content" => "some content",
        "drafterOpinion" => "some drafter_opinion",
        "approvalLines" => [%{"sequence" => 1, "approver_id" => approver_id}]
      }

      conn = put_req_header(conn, "x-user-id", "#{drafter_id}")

      # when
      conn = post(conn, Routes.document_path(conn, :draft), params)

      # then
      assert response = json_response(conn, 201)

      assert drafter_id == response["drafterId"]
      assert params["title"] == response["title"]
      assert params["content"] == response["content"]
      assert params["drafterOpinion"] == response["drafterOpinion"]

      assert %{
               "approverId" => ^approver_id,
               "sequence" => 1,
               "actedAt" => nil,
               "opinion" => nil,
               "receivedAt" => nil
             } = hd(response["approvalLines"])
    end
  end

  describe "approve" do
    test "confirm document", %{conn: conn} do
      # given
      %{id: document_id, approval_lines: [%{approver_id: approver_id}]} = document_fixture()
      opinion = "confirm!!!"

      params = %{
        "opinion" => opinion
      }

      conn = put_req_header(conn, "x-user-id", "#{approver_id}")

      # when
      conn = put(conn, Routes.document_path(conn, :approve, document_id, :confirm), params)

      # then
      assert %Document{} =
               document = Repo.get(Document, document_id) |> Repo.preload(:approval_lines)

      assert %{
               status: :CONFIRMED,
               approval_lines: [
                 %{approval_type: :CONFIRMED, opinion: ^opinion, acted_at: acted_at}
               ]
             } = document

      refute is_nil(acted_at)
    end

    test "Not found document error when confirm document", %{conn: conn} do
      conn = put_req_header(conn, "x-user-id", "1")

      conn =
        put(conn, Routes.document_path(conn, :approve, -1, :confirm), %{"opinion" => "confirm!!!"})

      assert %{"errors" => %{"detail" => "Not Found"}} == json_response(conn, 404)
    end
  end
end
