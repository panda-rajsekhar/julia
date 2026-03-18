using Random
using Plots

# Force GR backend 
gr()

# -------------------------------
# Generate Maze using DFS
# -------------------------------
function generate_maze(height, width)

    visited = falses(height, width)
    h_walls = trues(height+1, width)
    v_walls = trues(height, width+1)

    directions = [(0,1),(1,0),(0,-1),(-1,0)]

    stack = [(1,1)]
    visited[1,1] = true

    while !isempty(stack)

        x,y = stack[end]

        shuffle!(directions)

        moved = false

        for (dx,dy) in directions
            nx, ny = x+dx, y+dy

            if 1 ≤ nx ≤ height && 1 ≤ ny ≤ width && !visited[nx,ny]

                if dx == 0
                    v_walls[x, min(y,ny)+1] = false
                else
                    h_walls[min(x,nx)+1, y] = false
                end

                visited[nx,ny] = true
                push!(stack,(nx,ny))

                moved = true
                break
            end
        end

        if !moved
            pop!(stack)
        end
    end

    h_walls[1,1] = false
    h_walls[height+1,width] = false

    return h_walls, v_walls
end


# -------------------------------
# BFS Shortest Path
# -------------------------------
function find_shortest_path(height::Int, width::Int,
                            h_walls::BitMatrix,
                            v_walls::BitMatrix)

    start = (1, 1)
    goal = (height, width)

    directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]
    visited = falses(height, width)

    queue = [(start, [start])]
    visited[1, 1] = true

    while !isempty(queue)
        current = popfirst!(queue)
        pos = current[1]
        path = current[2]

        x, y = pos

        if pos == goal
            return path
        end

        for (dx, dy) in directions
            nx, ny = x + dx, y + dy

            if 1 ≤ nx ≤ height && 1 ≤ ny ≤ width && !visited[nx, ny]

                wall_blocked = if dx == 0
                    v_walls[x, min(y, ny) + 1]
                else
                    h_walls[min(x, nx) + 1, y]
                end

                if !wall_blocked
                    visited[nx, ny] = true
                    new_path = copy(path)
                    push!(new_path, (nx, ny))
                    push!(queue, ((nx, ny), new_path))
                end
            end
        end
    end

    return nothing
end

# -------------------------------
# Plot Maze
# -------------------------------
function plot_maze_fast(height, width, h_walls, v_walls, path)

    xs = Float64[]
    ys = Float64[]

    # Horizontal walls
    for i in 1:height+1
        for j in 1:width
            if h_walls[i, j]
                push!(xs, j-1); push!(ys, height-(i-1))
                push!(xs, j);   push!(ys, height-(i-1))
                push!(xs, NaN); push!(ys, NaN)
            end
        end
    end

    # Vertical walls
    for i in 1:height
        for j in 1:width+1
            if v_walls[i, j]
                push!(xs, j-1); push!(ys, height-(i-1))
                push!(xs, j-1); push!(ys, height-i)
                push!(xs, NaN); push!(ys, NaN)
            end
        end
    end

    p = plot(xs, ys,
        color=:black,
        linewidth=2,
        size=(1000,1000),
        legend=false,
        axis=false,
        ticks=false,
        aspect_ratio=1
    )

    # Path
    if path !== nothing
        px = [y - 0.5 for (_, y) in path]
        py = [height - (x - 0.5) for (x, _) in path]

        plot!(px, py,
            color=:red,
            linewidth=2)
    end

    xlims!(0,width)
    ylims!(0,height)

    return p
end

# -------------------------------
# Main
# -------------------------------
function main()
    Random.seed!(42)

    height =300
    width =300

    h_walls, v_walls = generate_maze(height, width)
    path = find_shortest_path(height, width, h_walls, v_walls)

    p = plot_maze_fast(height, width, h_walls, v_walls, path)

    savefig(p, "output.png")
    println("Maze saved as output.png")
end

main()
