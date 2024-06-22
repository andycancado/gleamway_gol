import gleam/float
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/result
import gleam/string

const num_generations: Int = 5

pub fn gol(grid: List(List(Int)), generation: Int) {
  case generation {
    n if n > num_generations -> Nil
    _ -> {
      let n = list.length(grid)
      let m = list.length(list.first(grid) |> result.unwrap([]))

      let x =
        list.index_map(grid, fn(row, i) {
          list.index_map(row, fn(cell_state, j) {
            let live_neighbors =
              iterator.range(-1, 1)
              |> iterator.flat_map(fn(x) {
                iterator.range(-1, 1)
                |> iterator.map(fn(y) {
                  let new_x = i + x
                  let new_y = j + y
                  case new_x >= 0 && new_y >= 0 && new_x < n && new_y < m {
                    True ->
                      iterator.from_list(grid)
                      |> iterator.at(new_x)
                      |> result.then(fn(row) {
                        iterator.from_list(row) |> iterator.at(new_y)
                      })
                      |> result.unwrap(0)
                    False -> 0
                  }
                })
              })
              |> iterator.fold(0, fn(acc, val) { acc + val })
            let live_neighbors = live_neighbors - cell_state

            // io.println(int.to_string(live_neighbors))
            case cell_state, live_neighbors {
              1, ln if ln < 2 -> 0
              1, ln if ln > 3 -> 0
              0, 3 -> 1
              // 1, 3 -> 1
              _, _ -> 0
            }
          })
        })
      clear_screen()
      io.print("generation: ")
      generation |> int.to_string |> io.println
      print_grid(x)
      io.println("")
      expensive_calculation()
      gol(x, generation + 1)
    }
  }
}

pub fn expensive_calculation() -> Int {
  let upper_limit = 1_000_000

  iterator.range(2, upper_limit)
  |> iterator.filter(fn(n) {
    iterator.range(2, int.square_root(n) |> result.unwrap(0.0) |> float.round)
    |> iterator.all(fn(i) { n % i != 0 })
  })
  |> iterator.to_list
  |> list.length
}

// chatgpt doing things here 😃 
// pub fn list_at(lst: List(a), index: Int) -> Result(a, Nil) {
//   case index < 0 {
//     True -> Error(Nil)
//     False -> do_list_at(lst, index)
//   }
// }
//
// fn do_list_at(lst: List(a), index: Int) -> Result(a, Nil) {
//   case lst, index {
//     [], _ -> Error(Nil)
//     [head, ..], 0 -> Ok(head)
//     [_, ..tail], i -> do_list_at(tail, i - 1)
//   }
// }

fn print_grid(grid: List(List(Int))) {
  grid
  |> list.map(fn(row) {
    row
    |> list.map(fn(cell) {
      case cell {
        0 -> ". "
        // n -> int.to_string(n)
        _ -> "0 "
      }
    })
    // |> list.map(fn(x) { int.to_string(x) })
    |> string.join("")
  })
  |> string.join("\n")
  |> io.println
}

fn clear_screen() {
  io.print("\u{001B}[2J\u{001B}[H")
}

pub fn main() {
  let rows = 10
  let cols = 10
  let grid =
    list.index_map(list.range(0, rows - 1), fn(_, i) {
      list.index_map(list.range(0, cols - 1), fn(j, _) {
        case i, j {
          1, 2 -> 1
          2, 2 -> 1
          3, 2 -> 1
          _, _ -> 0
        }
      })
    })

  gol(grid, 1)
}
