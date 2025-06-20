defmodule QuickFactory.SequenceTest do
  use ExUnit.Case

  alias QuickFactory.Sequence

  setup do
    Sequence.reset()
  end

  test "increments the sequence each time it is called" do
    assert "joe0" == Sequence.next(:name, &"joe#{&1}")
    assert "joe1" == Sequence.next(:name, &"joe#{&1}")
  end

  test "traverses a list each time it is called" do
    assert "A" == Sequence.next(:name, ["A", "B", "C"])
    assert "B" == Sequence.next(:name, ["A", "B", "C"])
    assert "C" == Sequence.next(:name, ["A", "B", "C"])
    assert "A" == Sequence.next(:name, ["A", "B", "C"])
  end

  test "updates different sequences independently" do
    assert "joe0" == Sequence.next(:name, &"joe#{&1}")
    assert "joe1" == Sequence.next(:name, &"joe#{&1}")
    assert 0 == Sequence.next(:month, & &1)
    assert 1 == Sequence.next(:month, & &1)
  end

  test "can optionally set starting integer" do
    assert "100" == Sequence.next(:dollars_in_cents, &"#{&1}", start_at: 100)
    assert "101" == Sequence.next(:dollars_in_cents, &"#{&1}")
  end

  test "lets you quickly create sequences" do
    assert "Comment Body0" == Sequence.next("Comment Body")
    assert "Comment Body1" == Sequence.next("Comment Body")
  end

  test "only accepts strings for sequence shortcut" do
    assert_raise ArgumentError, ~r/must be a string/, fn ->
      Sequence.next(:not_a_string)
    end
  end

  test "can reset sequences" do
    Sequence.next("joe")

    Sequence.reset()

    assert "joe0" == Sequence.next("joe")
  end

  test "can reset specific sequences" do
    Sequence.next(:alphabet, ["A", "B", "C"])
    Sequence.next(:alphabet, ["A", "B", "C"])
    Sequence.next(:numeric, [1, 2, 3])
    Sequence.next(:numeric, [1, 2, 3])
    Sequence.next("joe")
    Sequence.next("joe")

    Sequence.reset(["joe", :numeric])

    assert 1 == Sequence.next(:numeric, [1, 2, 3])
    assert "joe0" == Sequence.next("joe")
    assert "C" == Sequence.next(:alphabet, ["A", "B", "C"])

    Sequence.reset(:alphabet)

    assert "A" == Sequence.next(:alphabet, ["A", "B", "C"])
    assert 2 == Sequence.next(:numeric, [1, 2, 3])
  end
end
