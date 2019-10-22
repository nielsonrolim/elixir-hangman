defmodule Hangman.GameTest do
  use ExUnit.Case

  alias Hangman.Game

  setup do
    game = Game.new_game("test")
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
      assert {^game, _tally} = Game.make_move(game, "x")
    end
  end

  test "first occurence of letter is not already used", context do
    game = context[:game]
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state != :already_used
  end

  test "second occurence of letter is already used", context do
    game = context[:game]
    {game, _tally} = Game.make_move(game, "x")
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "a good guess is recognized", context do
    game = context[:game]
    {game, _tally} = Game.make_move(game, "t")
    assert game.game_state == :good_guess
    assert game.turns_left == 7
  end

  test "a guessed word is a won game", context do
    moves = [
      {"t", :good_guess},
      {"e", :good_guess},
      {"s", :won}
    ]

    game = context[:game]

    Enum.reduce(moves, game, fn {guess, state}, new_game ->
      {new_game, _tally} = Game.make_move(new_game, guess)
      assert new_game.game_state == state
      assert game.turns_left == 7
      new_game
    end)
  end

  test "a bad guess is recognized", context do
    game = context[:game]
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state == :bad_guess
    assert game.turns_left == 6
  end

  test "a lost game is recognized", context do
    game = context[:game]

    moves = [
      {"x", :bad_guess},
      {"y", :bad_guess},
      {"z", :bad_guess},
      {"a", :bad_guess},
      {"b", :bad_guess},
      {"c", :bad_guess},
      {"d", :lost}
    ]

    Enum.reduce(moves, game, fn {guess, state}, new_game ->
      {new_game, _tally} = Game.make_move(new_game, guess)
      assert new_game.game_state == state
      new_game
    end)
  end
end
