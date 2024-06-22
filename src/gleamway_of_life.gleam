import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/result
import gleam/string

const num_generations: Int = 50

pub fn gol(grid: List(List(Int)), generation: Int) {
  case generation {
    n if n > num_generations -> Nil
    _ -> {
      let n = list.length(grid)
      let m =
        grid
        |> list.first
        |> result.unwrap([])
        |> list.length

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
            case cell_state, live_neighbors {
              1, ln if ln < 2 -> 0
              1, ln if ln > 3 -> 0
              1, ln if ln == 3 || ln == 2 -> 1
              0, 3 -> 1
              _, _ -> 0
            }
          })
        })
      process.sleep(1000)
      clear_screen()
      io.print("generation: ")

      generation
      |> int.to_string
      |> io.println

      print_grid(x)
      io.println("")
      gol(x, generation + 1)
    }
  }
}

fn print_grid(grid: List(List(Int))) {
  grid
  |> list.map(fn(row) {
    row
    |> list.map(fn(cell) {
      case cell {
        0 -> ". "
        _ -> "▇ "
      }
    })
    |> string.join("")
  })
  |> string.join("\n")
  |> io.println
}

fn clear_screen() {
  io.print("\u{001B}[2J\u{001B}[H")
}

pub fn main() {
  let rows = 20
  let cols = 20
  let grid =
    list.index_map(list.range(0, rows - 1), fn(_, i) {
      list.index_map(list.range(0, cols - 1), fn(j, _) {
        case i, j {
          4, 3 -> 1
          4, 4 -> 1
          4, 5 -> 1
          5, 2 -> 1
          5, 3 -> 1
          5, 4 -> 1
          _, _ -> 0
        }
      })
    })

  clear_screen()
  io.println("Initial Grid")
  print_grid(grid)
  gol(grid, 1)
}
