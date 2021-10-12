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
      params = %{
        title: "some title",
        content: "some content",
        drafter_id: 42,
        drafter_opinion: "some drafter_opinion",
        "approval_lines": [%{sequence: 1, approver_id: 11}]
      }

      # when
      conn = post(conn, Routes.document_path(conn, :draft), params)

      assert params.title == json_response(conn, 201)["title"]
      assert params.content == json_response(conn, 201)["content"]
      assert params.drafter_id == json_response(conn, 201)["drafterId"]
      assert params.drafter_opinion == json_response(conn, 201)["drafterOpinion"]
      # TODO: assert approve lines
    end
  end
end
