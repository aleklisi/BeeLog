module OrderTest exposing (suite)

import Expect
import Main exposing (moveById, normalizeOrder, replaceVisibleItems)
import Test exposing (..)


suite : Test
suite =
    describe "drag and drop ordering"
        [ test "moves an item to the beginning" <|
            \_ ->
                Expect.equal [ "a", "b", "c" ] (moveById identity "a" "b" False [ "b", "a", "c" ])
        , test "moves an item before a middle target" <|
            \_ ->
                Expect.equal [ "a", "c", "b", "d" ] (moveById identity "c" "b" False [ "a", "b", "c", "d" ])
        , test "moves an item after a target at the end" <|
            \_ ->
                Expect.equal [ "a", "c", "b" ] (moveById identity "b" "c" True [ "a", "b", "c" ])
        , test "does not change the list when dropped on itself" <|
            \_ ->
                Expect.equal [ "a", "b" ] (moveById identity "a" "a" True [ "a", "b" ])
        , test "does not change the list for an unknown target" <|
            \_ ->
                Expect.equal [ "a", "b" ] (moveById identity "a" "missing" False [ "a", "b" ])
        , test "normalizes missing or duplicated order values deterministically" <|
            \_ ->
                let
                    items = [ { id = "a", order = 8 }, { id = "b", order = 8 }, { id = "c", order = -1 } ]
                    normalized = normalizeOrder (\item index -> { item | order = index }) items
                in
                Expect.equal [ 0, 1, 2 ] (List.map .order normalized)
        , test "merges a reordered visible subset without moving hidden items" <|
            \_ ->
                let
                    allItems = [ { id = "a", hidden = False }, { id = "hidden", hidden = True }, { id = "b", hidden = False } ]
                    visible = List.filter (\item -> not item.hidden) allItems
                    reordered = moveById .id "a" "b" True visible
                    merged = replaceVisibleItems .id visible reordered allItems
                in
                Expect.equal [ "b", "hidden", "a" ] (List.map .id merged)
        ]
