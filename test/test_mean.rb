$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'mean'
require 'colorize'
require 'maxitest/autorun'

class MeanTest < Minitest::Test

   i_suck_and_my_tests_are_order_dependent!
  # helper method to split array into equally sizes parts {{{
  def splitArray(size, splitCount)
    indexSplit = []
    (0...splitCount).each {|s|
      (0...size).each {|i|
        (indexSplit[s] ||= []) << i if i <= size.to_f/(splitCount.to_f)*(s+1)
      }
    }

    (1..(splitCount-1)).to_a.reverse.each {|i|
      indexSplit[i] = indexSplit[i]-indexSplit[i-1]
    }

    indexSplit
  end
  def test_split_array
    values = Array.new(10) {rand}

    expectedResult = [[0, 1, 2], [3, 4, 5], [6, 7], [8, 9]]

    result = splitArray(values.size,4)
    assert_equal(result, expectedResult)
  end
  # }}}


  # methods for creating test data, test weights and some more options to tuning  {{{
  #   size: amount random data values
  #   weight: basic weight for later averaging
  #   scale: list of scale factors for the list of weights, i.e. the list of
  #   weights it splitten into equally sized parts and each of them is
  #   multiplied with the factor from the argument list
  #   list: if this is given, it overwrites the random values for the data set
  def setValues(size, weight, valueScale: 1.0, weightScale: [], list: [], offset: 0.0)
    testSet     = Array.new(size) {rand**Math.log(rand).abs*1000}
    testSet     = list.empty? ? Array.new(size) {rand * valueScale}  : list
    testSet.map! {|i| i += offset}

    testWeights = Array.new(size) {weight}
    unless weightScale.empty? then
      splittedIndices = splitArray(size, weightScale.size)
      splittedIndices.each_with_index {|is,si|
        is.each {|i| 
          testWeights[i] = weightScale[si]*testWeights[i]
        }
      }
    end

    expectedMean = MeanProcesing::arith_jfe(testSet)

    [testSet, testWeights, expectedMean]
  end #}}}

  # setup variation for testing the different averaging algorhithms
  def setupSmall
    @@testSet = (0..9).to_a
    @@expectedMean = 4.5
    @@testWeights = Array.new(@@testSet.size) {0.5}
    @@expectedRunMean = [0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5]
  end
  def setupSmallWeighted
    @@testSet, @@testWeights, @@expectedMean = setValues(10,1.0,weightScale: [0.5,1,2],list: (0..9).to_a)
    assert_equal(@@expectedMean, 4.5)
  end
  def setupMedium
    size, weight = 720, 2
    @@testSet, @@testWeights, @@expectedMean = setValues(size,weight)
  end
  def setupMediumOcean
    size, weight = 720, 2
    @@testSet, @@testWeights, @@expectedMean = setValues(size,weight,offset: -2.0, valueScale: 30.0)
  end
  def setupMediumDifferentWeights
    size, weight, weight_scale = 720, 1, [2,1,0.5]
    @@testSet, @@testWeights, @@expectedMean = setValues(size,weight,weight_scale)
  end
  def setupLarge
    size, weight = 100000, 1800
    @@testSet, @@testWeights, @@expectedMean = setValues(size,weight)
  end
  def setupLargeOffset
    size, weight, offset, valueScale = 100000, 1.0, 273.0, 50.0
    @@testSet, @@testWeights, @@expectedMean = setValues(size,weight, offset: offset, valueScale: valueScale)
  end

  def setup
    case ENV['SETUP']
    when 's'  then setupSmall
    when 'sw' then setupSmallWeighted
    when 'm'  then setupMedium
    when 'mo' then setupMediumOcean
    when 'mw' then setupMediumDifferentWeights
    when 'l'  then setupLarge
    when 'lo' then setupLargeOffset
    else setupSmall end
  end
  def showTestRange(name,mean)
    ["\t#{name}: #{mean.round(4)}|\n\t\t",
      "abs: #{@@expectedMean - mean}|\n\t\trel: ",
     "#{@@expectedMean*100/mean}%".colorize(color: :green),
     "\n\t\t(data:#{@@testSet.min} .. #{@@testSet.max})".colorize(color: :blue)].join
  end

  def test_arith_jfe
    mean = MeanProcesing::arith_jfe(@@testSet)
    puts showTestRange('test_arith_jfe',mean)
  end
  def test_add_div
    mean = MeanProcesing::add_div(@@testSet)
    meanJ = MeanProcesing::arith_jfe(@@testSet)
    puts showTestRange('test_add_div',mean)
  end
  def test_weighted
    mean = MeanProcesing::weighted_mean(@@testSet, @@testWeights)
    puts showTestRange('test_weighted',mean)
  end
  def test_run_mean
    mean = MeanProcesing::running_mean(@@testSet)
    puts showTestRange("test_run_mean",mean)
  end
  def test_run_weighted_mean
    mean = MeanProcesing::weighted_running_mean(@@testSet, @@testWeights)
    puts showTestRange('test_run_weighted_mean',mean)
  end

  def _test_medium
    setupMedium
    pp @@testSet
  end
end

#vim: fdm=marker
