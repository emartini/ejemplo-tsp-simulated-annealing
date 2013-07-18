require 'csv'
require 'pp'

class SimulatedAnnealing

    attr_accessor   :random_list,
                    :cost_matrix,
                    :solution_best,
                    :solution_current,
                    :temp,
                    :current_neighborhood

    def initialize(initial_path, temp, proc = Proc.new)

        self.create_cost_matrix.create_random_list

        self.solution_current = {
            path: initial_path,
            cost: self.calulate_cost(initial_path)
        }

        @cooling_proc = proc
        self.solution_best = self.solution_current
        self.temp = temp.to_f
    end

    def cool 
        self.temp = @cooling_proc.call(self.temp)
    end

    def create_random_list
        self.random_list = []
        File.open("randoms.txt", "r").each_line{|l| self.random_list << l.to_f}
        self.random_list.reverse!
        self
    end

    def create_cost_matrix
        self.cost_matrix = CSV.read("cost_matrix.csv")
        self
    end

    def calulate_cost(p)
        sum = 0
        path_lenght = p.length-2

        for i in 0..path_lenght
            sum += (self.cost_matrix[p[i]-1][p[i+1]-1]).to_i
        end

        sum 
    end

    def create_neighborhood
        new_neighborhood = []
        neighborhood_lenght = self.solution_current[:path].length - 1

        for i in 0..neighborhood_lenght
            move = self.swap(i)
            if move
                neighbor = {
                    path: move,
                    cost: self.calulate_cost(move),
                    probability: (1.0 + i)/(neighborhood_lenght)
                }
                new_neighborhood << neighbor
            end
        end
        self.current_neighborhood = new_neighborhood
    end
 
    def swap(idx)        
        n   = self.solution_current[:path].clone
        aux = n[idx]
        if (idx + 1) < n.length
            n[idx]   = n[idx+1]
            n[idx+1] = aux
            return n
        else
            return nil    
        end        
    end

end

sa = SimulatedAnnealing.new(
    [10, 2, 5, 6, 4, 9, 3, 8, 7, 1], 
    t=300, 
    Proc.new {|t| t *= 0.9} 
)

iterations_count = 1

puts [
    'Temperatura',
    'Iteración',
    'Mejor solución',
    'Solución actual',
    'Solución candidata',
    'Número aleatorio',
    'Delta',
    'Probabilidad',
    'Estado'
].join(',')

loop do

    sa.create_neighborhood
    original_sb = sa.solution_best

    loop do
        exit_criteria = false
        delta  = nil
        prob   = nil
        state  = 'Rechazado'
        random = sa.random_list.pop
        original_sc = sa.solution_current
        candidate = {}
        iterations_count += 1

        sa.current_neighborhood.each do |n|
            if random <= n[:probability]
                candidate = n
                break
            end
        end

        if candidate[:cost] < sa.solution_current[:cost]
            sa.solution_current = candidate
            state = 'Mejora'
            exit_criteria  = true
        else
            delta  = sa.solution_current[:cost] - candidate[:cost]
            random = sa.random_list.pop
            prob   = Math.exp(delta/sa.temp)
            
            if random <  prob #lo acepto
                sa.solution_current = candidate
                exit_criteria = true
                state = 'Aceptado'
            end
        end

        puts [
            sa.temp.to_i,
            iterations_count-1,
            "[#{sa.solution_best[:path].join('-')}](#{sa.solution_best[:cost]})",
            "[#{original_sc[:path].join('-')}](#{original_sc[:cost]})",
            "[#{candidate[:path].join('-')}](#{candidate[:cost]})",
            random,
            delta.to_s,
            p,
            state    
        ].join(",")

        if sa.solution_current[:cost] < sa.solution_best[:cost]
            sa.solution_best = sa.solution_current
        end
        break if exit_criteria
    end

    if (iterations_count % 10 == 0) && sa.cool < 160     
        break
    end 
end
