module MeanProcesing

  # addthings up and dov by number for additions
  def MeanProcesing::add_div(list)
    list.reduce(:+)/list.size.to_f
  end

  def MeanProcesing.weighted_mean(list,weights)
    [list,weights].transpose.map {|v,w| v*w}.reduce(:+) / weights.reduce(:+).to_f
  end

  def MeanProcesing.running_mean(list)
    m    = Array.new(list.size)
    m[0] = list[0]
    (1...list.size).each {|i|
      m[i] = (i*m[i-1] + list[i])/(i+1).to_f # j = i+1
#     m[i-1] = ((i)*m[i-2] + list[i-1])/(i).to_f # j = i-1
#     m[j] = (i*m[j-1] + list[j])/i
#
#     m    = i/(i+1) * m + 1/j * list[i]
#     1 - 1/(i+1)
    }
    m.last
  end

  def MeanProcesing.arith_jfe(list)
    size   = list.size.to_f
    values = list.map {|v| v/size}
    values.reduce(:+)
  end

  def MeanProcesing.weighted_running_mean(list,weights)
    # precompute partial sums of weights
    sum_weights    = Array.new(weights.size) {0}
    sum_weights[0] = weights[0]
    (1...sum_weights.size).each {|i|
      sum_weights[i] = sum_weights[i-1] + weights[i]
    }

    m    = Array(list.size)
    m[0] = list[0]*weights[0]
    (1...list.size).each {|i|
      # wgt = 1/i (dtime/(current_time - start_time)
      m[i] = (sum_weights[i-1]*m[i-1] + weights[i]*list[i])/sum_weights[i].to_f
#     m[i] = (sum_weights[i-1]/sum_weights[i]) * m[i-1] + (weights[i]/sum_weights[i]) * list[i]
#     # psi_avg_new = (1._wp - wgt)*psi_avg_old + wgt*psi_insta
#      m = (1 - 1/i)*m + 1/i * v
#      m[k] = (1 - 1/i)*m[k-1] + 1/i * v[k]
#      m[k] = (i/i - 1/i)*.....+....
#      m[k] = (i-1)/i * m + v[k]/i
#      m[k] = ((i-1) * m[k-1] + v[k] )/i
    }
    m.last
  end
end
