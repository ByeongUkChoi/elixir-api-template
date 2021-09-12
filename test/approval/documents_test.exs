defmodule Approval.DocumentsTest do
  use Approval.DataCase

  alias Approval.Documents

  describe "documents" do
    alias Approval.Documents.Document

    @valid_attrs %{content: "some content", drafter_id: 42, drafter_opinion: "some drafter_opinion", title: "some title", approval_lines: [%{sequence: 1, approver_id: 11}]}
    # @update_attrs %{content: "some updated content", drafter_id: 43, drafter_opinion: "some updated drafter_opinion", title: "some updated title"}
    # @invalid_attrs %{content: nil, drafter_id: nil, drafter_opinion: nil, title: nil}

    def document_fixture(attrs \\ %{}) do
      {:ok, document} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Documents.create_document()

      document
    end

    test "get_document_with_approval_lines!/1 returns the document with given id" do
      document = document_fixture()
      assert Documents.get_document_with_approval_lines!(document.id) == document
    end
  end
end
