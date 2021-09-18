defmodule Approval.DocumentsTest do
  use Approval.DataCase

  import Ecto.Changeset

  alias Approval.Documents
  alias Approval.Documents.Document

  describe "documents context test" do

    @valid_attrs %{
      title: "some title",
      content: "some content",
      drafter_id: 42,
      drafter_opinion: "some drafter_opinion",
      status: "ON_PROGRESS",
      approval_lines: [%{sequence: 1, approver_id: 11, received_at: ~N[2000-01-01 23:00:07]}]
    }
    # @update_attrs %{content: "some updated content", drafter_id: 43, drafter_opinion: "some updated drafter_opinion", title: "some updated title"}
    # @invalid_attrs %{content: nil, drafter_id: nil, drafter_opinion: nil, title: nil}

    def document_fixture(attrs \\ %{}) do
      {:ok, document} =
        %Document{}
        |> Document.changeset(Enum.into(attrs, @valid_attrs))
        |> Repo.insert()

      document
    end

    test "get_document_with_approval_lines!/1 returns the document with given id" do
      # given
      document = document_fixture()
      # when & then
      assert document == Documents.get_document_with_approval_lines!(document.id)
    end

    test "get_document_list/1 returns all documents without approval lines" do
      # given
      document = document_fixture()

      # when
      {documents, _paginagion} = Documents.get_document_list(%{})

      # then
      documents_withou_approval_lines = Enum.map(documents, &Map.delete(&1, :approval_lines))
      assert documents_withou_approval_lines == [Map.delete(document, :approval_lines)]
    end

    test "draft_document/1 with valid data creates a document" do
      assert {:ok, %Document{} = document} = Documents.draft_document(@valid_attrs)
      assert @valid_attrs = document
    end

    test "approve :confirm" do
    end
  end
end
