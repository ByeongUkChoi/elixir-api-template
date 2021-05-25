defmodule Approval.ApprovalLinesTest do
  use Approval.DataCase

  alias Approval.ApprovalLines

  describe "approval_lines" do
    alias Approval.ApprovalLines.ApprovalLine

    @valid_attrs %{acted_at: ~N[2010-04-17 14:00:00], approval_type: "some approval_type", approver_id: 42, opinion: "some opinion", received_at: ~N[2010-04-17 14:00:00], sequence: 42}
    @update_attrs %{acted_at: ~N[2011-05-18 15:01:01], approval_type: "some updated approval_type", approver_id: 43, opinion: "some updated opinion", received_at: ~N[2011-05-18 15:01:01], sequence: 43}
    @invalid_attrs %{acted_at: nil, approval_type: nil, approver_id: nil, opinion: nil, received_at: nil, sequence: nil}

    def approval_line_fixture(attrs \\ %{}) do
      {:ok, approval_line} =
        attrs
        |> Enum.into(@valid_attrs)
        |> ApprovalLines.create_approval_line()

      approval_line
    end

    test "list_approval_lines/0 returns all approval_lines" do
      approval_line = approval_line_fixture()
      assert ApprovalLines.list_approval_lines() == [approval_line]
    end

    test "get_approval_line!/1 returns the approval_line with given id" do
      approval_line = approval_line_fixture()
      assert ApprovalLines.get_approval_line!(approval_line.id) == approval_line
    end

    test "create_approval_line/1 with valid data creates a approval_line" do
      assert {:ok, %ApprovalLine{} = approval_line} = ApprovalLines.create_approval_line(@valid_attrs)
      assert approval_line.acted_at == ~N[2010-04-17 14:00:00]
      assert approval_line.approval_type == "some approval_type"
      assert approval_line.approver_id == 42
      assert approval_line.opinion == "some opinion"
      assert approval_line.received_at == ~N[2010-04-17 14:00:00]
      assert approval_line.sequence == 42
    end

    test "create_approval_line/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ApprovalLines.create_approval_line(@invalid_attrs)
    end

    test "update_approval_line/2 with valid data updates the approval_line" do
      approval_line = approval_line_fixture()
      assert {:ok, %ApprovalLine{} = approval_line} = ApprovalLines.update_approval_line(approval_line, @update_attrs)
      assert approval_line.acted_at == ~N[2011-05-18 15:01:01]
      assert approval_line.approval_type == "some updated approval_type"
      assert approval_line.approver_id == 43
      assert approval_line.opinion == "some updated opinion"
      assert approval_line.received_at == ~N[2011-05-18 15:01:01]
      assert approval_line.sequence == 43
    end

    test "update_approval_line/2 with invalid data returns error changeset" do
      approval_line = approval_line_fixture()
      assert {:error, %Ecto.Changeset{}} = ApprovalLines.update_approval_line(approval_line, @invalid_attrs)
      assert approval_line == ApprovalLines.get_approval_line!(approval_line.id)
    end

    test "delete_approval_line/1 deletes the approval_line" do
      approval_line = approval_line_fixture()
      assert {:ok, %ApprovalLine{}} = ApprovalLines.delete_approval_line(approval_line)
      assert_raise Ecto.NoResultsError, fn -> ApprovalLines.get_approval_line!(approval_line.id) end
    end

    test "change_approval_line/1 returns a approval_line changeset" do
      approval_line = approval_line_fixture()
      assert %Ecto.Changeset{} = ApprovalLines.change_approval_line(approval_line)
    end
  end
end
