$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'mean'
require 'minitest/autorun'

class MeanTest < Minitest::Test

  # helper method to split array into equally sizes parts
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


  # methods for creating test data, test weights and some more options to tuning
  #   size: amount random data values
  #   weight: basic weight for later averaging
  #   scale: list of scale factors for the list of weights, i.e. the list of
  #   weights it splitten into equally sized parts and each of them is
  #   multiplied with the factor from the argument list
  #   list: if this is given, it overwrites the random values for the data set
  def setValues(size, weight, scale: [], list: [])
    testSet     = Array.new(size) {rand**Math.log(rand).abs*1000}
    testSet     = list.empty? ? Array.new(size) {rand}  : list

    testWeights = Array.new(size) {weight}
    unless scale.empty? then
      splittedIndices = splitArray(size, scale.size)
      splittedIndices.each_with_index {|is,si|
        is.each {|i| 
          testWeights[i] = scale[si]*testWeights[i]
        }
      }
    end

    expectedMean = MeanProcesing::arith_jfe(testSet)

    [testSet, testWeights, expectedMean]
  end

  # setup variation for testing the different averaging algorhithms
  def setupSmall
    @@testSet = (0..9).to_a
    @@expectedMean = 4.5
    @@testWeights = Array.new(@@testSet.size) {0.5}
    @@expectedRunMean = [0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5]
  end
  def setupSmallWeighted
    @@testSet, @@testWeights, @@expectedMean = setValues(10,1.0,scale: [0.5,1,2],list: (0..9).to_a)
    assert_equal(@@expectedMean, 4.5)
  end
  def setupMedium
    size = 720
    weight = 2
    @@testSet, @@testWeights, @@expectedMean = setValues(size,weight)
  end
  def setupMediumDifferentWeights
    size = 720
    weight = 1
    weight_scale = [2,1,0.5]
    @@testSet, @@testWeights, @@expectedMean = setValues(size,weight,weight_scale)
  end
  def setupLarge
    size = 100000
    weight = 1800
    @@testSet, @@testWeights, @@expectedMean = setValues(size,weight)
  end

  def setup
    case ENV['SETUP']
    when 's'
      setupSmall
    when 'sw'
      setupSmallWeighted
    when 'm'
      setupMedium
    when 'mw'
      setupMediumDifferentWeights
    when 'l'
      setupLarge
    else
      setupSmall
    end
  end

  def test_setup_10
    setupSmallWeighted
    pp @@testWeights
    pp @@testSet
  end

  def test_arith_jfe
    mean = MeanProcesing::arith_jfe(@@testSet)
    puts "AddDiv Mean value of |#{@@testSet.min} .. #{@@testSet.max}|: #{mean}"
    puts 'test_arith_jfe:'
    puts "Diff: #{@@expectedMean - mean} (#{@@expectedMean*100/mean}%)"
  end
  def test_add_div
    mean = MeanProcesing::add_div(@@testSet)
    meanJ = MeanProcesing::arith_jfe(@@testSet)
    puts "AddDiv Mean value of |#{@@testSet.min} .. #{@@testSet.max}|: #{mean} #{meanJ}"
    #assert_equal(@@expectedMean,mean)
  end
  def test_weighted
    mean =  MeanProcesing::weighted_mean(@@testSet, @@testWeights)
#   assert_equal(@@expectedMean,mean)
    puts 'test_weighted:'
    puts "Diff: #{@@expectedMean - mean} (#{@@expectedMean*100/mean}%)"
  end
  def test_run_mean
    mean = MeanProcesing::running_mean(@@testSet)
#   assert_equal(@@expectedMean,mean)
    puts 'test_run_mean:'
    puts "Diff: #{@@expectedMean - mean} (#{@@expectedMean*100/mean}%)"
  end
  def test_run_weighted_mean
    mean = MeanProcesing::weighted_running_mean(@@testSet, @@testWeights)
#   assert_equal(@@expectedMean,mean)
    puts "test_run_weighted_mean:"
    puts "Diff: #{@@expectedMean - mean} (#{@@expectedMean*100/mean}%)"
  end

  def _test_medium
    setupMedium
    pp @@testSet
  end
end
