defmodule Hangman.GameTest do
  use ExUnit.Case

  alias Hangman.Game

  setup do
    game = Game.new_game()
    {:ok, game: game}
  end

  test "new game returns structure", context do
    assert context[:game].turns_left == 7
    assert context[:game].game_state == :initializing
    assert length(context[:game].letters) > 0
  end

  test "letters are all ASCII characters", context do
    assert Enum.all?(context[:game].letters, fn x -> x =~ ~r/[a-z]/i end)
  end

  test "state isn't changed for :won or :lost game", context do
    for state <- [:won, :lost] do
      game = context[:game] |> Map.put(:game_state, state)
      assert {^game, _} = Game.make_move(game, "x")
    end
  end

  test "first occurence of letter is not already used", context do
    game = context[:game]
    { game, _tally } = Game.make_move(game, "x")
    assert game.game_state != :already_used
  end

  test "second occurence of letter is already used", context do
    game = context[:game]
    { game, _tally } = Game.make_move(game, "x")
    { game, _tally } = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end
end
