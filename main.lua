function love.load()
    require 'relogio'
    relogio:start()
    require 'class'
    require 'utils'
    require 'label'
    require 'graph'
    require 'help'
    require 'text_input'

    love.window.setTitle('Qx Graph Designer v0.3')
    love.window.setMode(800, 600, {resizable=true, vsync=false})

    myfont = love.graphics.newFont("LinLibertine_aDRS.ttf", Node.radius*1.2)
    
    print_labels = false
    inverted_colors = true
    love.graphics.setBackgroundColor(255, 255, 255)
    nodes_filled = false

    matrix_saved = 0
    matrix_saved_msg = "matrix saved to clipboard"
end

function love.draw()
    graph:draw()
    help:draw()

    love.graphics.setFont(help.font)
    love.graphics.setColor(40, 255, 80, matrix_saved)
    love.graphics.rectangle('fill', TX()/2 - help.font:getWidth(matrix_saved_msg)/2 - 10, 
        TY()/2 - help.font:getHeight(), help.font:getWidth(matrix_saved_msg)*0.9,
        help.font:getHeight(), 5)
    love.graphics.setColor(255, 255, 255, matrix_saved)
    love.graphics.print(matrix_saved_msg, TX()/2 - help.font:getWidth(matrix_saved_msg)/2,
        TY()/2 - help.font:getHeight(), 0, 0.85, 0.85)
    text_input:draw()
    labels_contr:draw()
end

function love.update(dt)
    relogio:update(dt)
    graph:update(dt)
    if matrix_saved > 0 then
        matrix_saved = matrix_saved - dt*100
        if matrix_saved < 0 then
            matrix_saved = 0
        end
    end
    labels_contr:update(dt)
end

function love.mousepressed(mx, my, key)
    if key == 1 then
        local i = graph:find_vertice(mx, my)
        local j = graph:find_edge_by_point(mx, my)
        local k = graph:find_edge_label(mx, my)
        local l = labels_contr:find(mx, my)
        if i then
            graph:move(i)
        elseif j then
            graph:move_edge(j)
        elseif k then
            graph:move_edge_label(k)
        elseif l then
            labels_contr:move(l, mx, my)
        else
            graph:addv(mx, my)
        end
    end
    if key == 2 then
        graph:start_edge(mx, my)
        local j = graph:find_edge_by_point(mx, my)
        if j then
            graph:reset_edge(j)
        end
    end
end

function love.mousereleased(mx, my, key)
    if key == 1 then
        if graph.moving then
            graph.moving = false
        end
        if graph.moving_edge then
            graph.moving_edge = false
        end
        if graph.moving_edge_label then
            graph.moving_edge_label = false
        end
        if labels_contr.moving_label then
            labels_contr.moving_label = false
        end
    end
    if key == 2 then
        graph:end_edge(mx, my)
    end
end
function love.wheelmoved(h, v)
    if h < 0 then
        local i = graph:find_vertice(love.mouse.getX(), love.mouse.getY())
        if i then
            graph:inc_radius(i)
        else
            graph:inc_radius()
        end
    elseif h > 0 then
        local i = graph:find_vertice(love.mouse.getX(), love.mouse.getY())
        if i then
            graph:dec_radius(i)
        else
            graph:dec_radius()
        end
    end
end

function love.keypressed(key)
    if text_input.is_open then
        if key == 'backspace' then
            text_input:backspace()
        elseif key == 'delete' then
            text_input:delete()
        elseif key == 'left' then
            text_input:left()
        elseif key == 'right' then
            text_input:right()
        elseif key == 'return' then
            local txt, buf = text_input:close()
            if buf[2] == 'edge' then
                graph.edges[buf[1]].label = txt
            elseif buf[2] == 'node' then
                graph.nodes[buf[1]].label = txt
            elseif buf == 'new label' then
                labels_contr:add(txt)
            end
        end
    else
        if key == 'e' then
            labels_contr:add_1(love.mouse.getX(), love.mouse.getY())
        end
        if key == 'p' then
            graph.print_it = true
        end
        if key == 'd' then
            if graph.directed then
                graph:clean_out()
                graph.directed = false
                local i = contain(graph.msgs, 'directed')
                if i then
                    graph.msgs[i] = 'undirected'
                end
            else
                graph:clean_out()
                graph.directed = true
                local i = contain(graph.msgs, 'undirected')
                if i then
                    graph.msgs[i] = 'directed'
                end
            end
        end
        if key == 'delete' then

            local i = graph:find_vertice(love.mouse.getX(), love.mouse.getY())
            labels_contr:delete(love.mouse.getX(), love.mouse.getY())
            if i then
                graph:remove(i)
            else
                i = graph:find_edge_by_point(love.mouse.getX(), love.mouse.getY())  
                if i then
                    graph:remove_edge(i)
                end
            end
        end
        if key == 'z' then
            if love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrk') then
                graph:undo()
            end
        end
        if key == 'escape' then
            if help.activated then
                help.activated = false
            end
        end
        if contain(key_colors, key) then
            local i = graph:find_vertice(love.mouse.getX(), love.mouse.getY())
            if i then
                graph:color_vertex(i, key)
            else
                i = graph:find_edge_by_point(love.mouse.getX(), love.mouse.getY())
                if i then
                    graph:color_edge(i, key)
                end

            end
        end
        if key == 'i' then
            if inverted_colors then
                love.graphics.setBackgroundColor(0, 0, 0)
                inverted_colors = false
            else
                love.graphics.setBackgroundColor(255, 255, 255)
                inverted_colors = true
            end
        end
        if key == 'f' then
            if nodes_filled then
                nodes_filled = false
            else
                nodes_filled = true
            end
        end
        if key == 's' then
            if graph.selecting_edges then
                graph.selecting_edges = false
            else
                graph.selecting_edges = true
            end
        end
        if key == 'l' then
            if print_labels then
                print_labels = false
            else
                print_labels = true
            end
        end
        if key == 'h' then
            if help.activated then
                help.activated = false
            else
                help.activated = true
            end
        end
        if key == 'a' then
            if love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift') then
                local i = graph:find_vertice()
                if i then
                    graph:v_point_to_all(i, 'in')
                end
            else
                local i = graph:find_vertice()
                if i then
                    graph:v_point_to_all(i)
                end
            end
        end
        if key == 'k' then
            if love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift') then
                local m = math.floor(#graph.nodes/2)
                local i = graph:find_vertice()
                if i then
                    m = i
                end
                graph:k_n_n(m)
            else
                if graph:is_complete() then
                    graph:clean_out()
                else
                    graph:k_n()
                end
            end
        end
        if help.activated then
            if key == 'left' then
                if help.page > 1 then
                    help.page = help.page - 1
                end
            end
            if key == 'right' then
                if help.page < help:num_pages() then
                    help.page = help.page + 1
                else
                    help.activated = false
                end
            end
        end
        if key == 'r' then
            if love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift') then
                graph:random_edges()
            else
                graph:random_vertices()
            end
        end
        if key == 'm' then
            love.system.setClipboardText( convert_matrix_to_python(graph:convert_to_matrix()))
            matrix_saved = 200
        end
        if key == 'c' then
            if graph.coloring then
                graph.coloring = false
                local i = contain(graph.msgs, 'coloring')
                if i then
                    table.remove(graph.msgs, i)
                end
            else
                graph.coloring = true
                table.insert(graph.msgs, 'coloring')
            end
        end
        if key == 'up' then
            graph:inc_radius()
        end
        if key == 'down' then
            graph:dec_radius()
        end
        if key == 'return' then
            --[[
            local j = graph:find_edge_by_point(love.mouse.getX(), love.mouse.getY()) or graph:find_edge_label(love.mouse.getX(), love.mouse.getY())
            local k = graph:find_vertice(love.mouse.getX(), love.mouse.getY())
            if j then
                text_input:open({j, 'edge'})
            elseif k then
                text_input:open({k, 'node'})
            end
            ]]--
        end
    end
end

function love.textinput(text)
    if not text_input.is_open then
        return
    end
    if text then
        text_input:insert(text)
        text_input.count = text_input.count + 1
    end
end