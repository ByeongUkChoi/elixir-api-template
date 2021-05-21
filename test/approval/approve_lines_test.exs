defmodule Approval.ApproveLinesTest do
  use Approval.DataCase

  alias Approval.ApproveLines

  describe "approve_lines" do
    alias Approval.ApproveLines.ApproveLine

    @valid_attrs %{acted_at: ~N[2010-04-17 14:00:00], approve_type: "some approve_type", approver_id: 42, opinion: "some opinion", received_at: ~N[2010-04-17 14:00:00], sequence: 42}
    @update_attrs %{acted_at: ~N[2011-05-18 15:01:01], approve_type: "some updated approve_type", approver_id: 43, opinion: "some updated opinion", received_at: ~N[2011-05-18 15:01:01], sequence: 43}
    @invalid_attrs %{acted_at: nil, approve_type: nil, approver_id: nil, opinion: nil, received_at: nil, sequence: nil}

    def approve_line_fixture(attrs \\ %{}) do
      {:ok, approve_line} =
        attrs
        |> Enum.into(@valid_attrs)
        |> ApproveLines.create_approve_line()

      approve_line
    end

    test "list_approve_lines/0 returns all approve_lines" do
      approve_line = approve_line_fixture()
      assert ApproveLines.list_approve_lines() == [approve_line]
    end

    test "get_approve_line!/1 returns the approve_line with given id" do
      approve_line = approve_line_fixture()
      assert ApproveLines.get_approve_line!(approve_line.id) == approve_line
    end

    test "create_approve_line/1 with valid data creates a approve_line" do
      assert {:ok, %ApproveLine{} = approve_line} = ApproveLines.create_approve_line(@valid_attrs)
      assert approve_line.acted_at == ~N[2010-04-17 14:00:00]
      assert approve_line.approve_type == "some approve_type"
      assert approve_line.approver_id == 42
      assert approve_line.opinion == "some opinion"
      assert approve_line.received_at == ~N[2010-04-17 14:00:00]
      assert approve_line.sequence == 42
    end

    test "create_approve_line/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ApproveLines.create_approve_line(@invalid_attrs)
    end

    test "update_approve_line/2 with valid data updates the approve_line" do
      approve_line = approve_line_fixture()
      assert {:ok, %ApproveLine{} = approve_line} = ApproveLines.update_approve_line(approve_line, @update_attrs)
      assert approve_line.acted_at == ~N[2011-05-18 15:01:01]
      assert approve_line.approve_type == "some updated approve_type"
      assert approve_line.approver_id == 43
      assert approve_line.opinion == "some updated opinion"
      assert approve_line.received_at == ~N[2011-05-18 15:01:01]
      assert approve_line.sequence == 43
    end

    test "update_approve_line/2 with invalid data returns error changeset" do
      approve_line = approve_line_fixture()
      assert {:error, %Ecto.Changeset{}} = ApproveLines.update_approve_line(approve_line, @invalid_attrs)
      assert approve_line == ApproveLines.get_approve_line!(approve_line.id)
    end

    test "delete_approve_line/1 deletes the approve_line" do
      approve_line = approve_line_fixture()
      assert {:ok, %ApproveLine{}} = ApproveLines.delete_approve_line(approve_line)
      assert_raise Ecto.NoResultsError, fn -> ApproveLines.get_approve_line!(approve_line.id) end
    end

    test "change_approve_line/1 returns a approve_line changeset" do
      approve_line = approve_line_fixture()
      assert %Ecto.Changeset{} = ApproveLines.change_approve_line(approve_line)
    end
  end
end
