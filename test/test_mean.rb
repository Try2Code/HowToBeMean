$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'mean'
require 'minitest/autorun'

class MeanTest < Minitest::Test

  def splitArray(size, splitCount)
    indexSplit = []
    (0...splitCount).each {|s|
      (0...size).each {|i|
        (indexSplit[s] ||= []) << i if i <= size.to_f/(splitCount.to_f)*(s+1)
      }
    }

    (1..(splitCount-1)).to_a.reverse.each {|i| indexSplit[i] = indexSplit[i]-indexSplit[i-1]}

    indexSplit
  end
  def test_split_array
    values = Array.new(10) {rand}

    expectedResult = [[0, 1, 2], [3, 4, 5], [6, 7], [8, 9]]

    result = splitArray(values.size,4)
    assert_equal(result, expectedResult)
  end
  def setValues(size, weight, scale=[])
    @@testSet     = Array.new(size) {rand**Math.log(rand).abs*1000}
    @@testSet     = Array.new(size) {rand}
    @@testWeights = Array.new(size) {weight}
    unless scale.empty? then
      splittedIndices = splitArray(size, scale.size)
      splittedIndices.each_with_index {|is,si| is.each {|i| @@testWeights[i] = scale[si]*@@testWeights[i]}}
    end
    @@expectedMean = MeanProcesing::arith_jfe(@@testSet)
  end
  def setupSmall
    @@testSet = (0..9).to_a
    @@expectedMean = 4.5
    @@testWeights = Array.new(@@testSet.size) {0.5}
    @@expectedRunMean = [0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5]
  end
  def setupSmallWeighted
    @@testSet = (0..9).to_a
    @@expectedMean = 4.5
    @@testWeights = Array.new(@@testSet.size) {1.0}
    setValues(@@testSet.size,[0.5,1,2])
  end
  def setupMedium
    size = 720
    weight = 2
    setValues(size,weight)
  end
  def setupMediumDifferentWeights
    size = 720
    weight = 1
    weight_scale = [2,1,0.5]
    setValues(size,weight,weight_scale)
  end
  def setupLarge
    size = 100000
    weight = 1800
    setValues(size,weight)
  end

  def setup
    setupMedium
  end

  def test_setup_10
    setupMediumDifferentWeights
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
