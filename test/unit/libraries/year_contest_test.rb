# frozen_string_literal: true

require "test_helper"

class YearContestTest < ActiveSupport::TestCase
  setup do
    @contest = YearContest.new
  end

  test "empty list" do
    result = @contest.run_on([])
    assert_equal [], result # rubocop:disable Minitest/AssertEmptyLiteral
  end

  test "one value in first day" do
    result = @contest.run_on([[1]])
    assert_equal [1], result
  end

  test "two values in first day" do
    result = @contest.run_on([[1, 2]])
    assert_equal 1, result.size
  end

  test "same value in first two days" do
    result = @contest.run_on([[1], [1]])
    assert_equal [1], result
  end

  test "same two values in first two days" do
    result = @contest.run_on([[1, 2], [1, 2]])
    assert_equal 2, result.size
  end

  test "third day empty" do
    result = @contest.run_on([[1], [2], [], [4]])
    assert_equal 2, result.size
  end

  test "third day nil" do
    result = @contest.run_on([[1], [2], nil, [4]])
    assert_equal 2, result.size
  end

  test "non destructive exclusion" do
    result = @contest.run_on([[1, 2], [3, 2], [4, 2], [1], [5, 2]])
    assert_equal 5, result.size
  end

  test "Year 2018" do
    # TODO: simplify
    obs = [
      [1755, 6658, 6975, 9147, 10111],
      [3686, 6602, 6631, 6975, 7046, 10023],
      [1755, 2361, 6602],
      [1755, 6602],
      [1755, 6602, 10202],
      [494, 1755, 6631, 10202, 10224],
      [1755],
      [1755, 6602, 6631, 6975, 7046, 9127, 10023],
      [1755, 6658],
      [1755],
      [6602, 6658],
      [6602, 6975],
      [1755],
      [1755, 3686, 3688, 6602, 6658, 6975, 7046],
      [1755, 6602, 6658],
      [6602, 6631],
      [1755, 6569, 6631, 6658, 6975, 7046, 10071, 10108, 10111, 10202],
      [6602, 6658, 6975],
      [6602, 6658, 6975, 10111],
      [1755, 10202],
      [514, 2439, 3688, 3742, 6569, 6602, 6658, 6975, 7046, 10023, 10111, 10202],
      [1755],
      [1755, 6602, 6975],
      [1755],
      [6602, 6631, 6975],
      [6602],
      [6631],
      [1755],
      [6602, 6658],
      [1755, 6658],
      [1755, 6602, 6658],
      [6975],
      [1755, 6602, 6658],
      [1755],
      [3686, 6975, 7046, 10023, 10202],
      [6602],
      [6602, 6975],
      [1755, 6658],
      [6602, 6658, 6975],
      [6658],
      [1755, 6658],
      [6658, 6975, 9147, 10111],
      [1755, 6602, 6658],
      [1755, 6602, 6658],
      [6602, 6658, 10202],
      [6602, 6658],
      [1755],
      [6658],
      [1755, 6602, 6658, 6975, 7046, 10111, 10202],
      [1755],
      [6602, 6658],
      [1755, 6658, 6975],
      [1755, 6602, 6658, 10202],
      [6602],
      [3688, 6658, 6975, 7046, 10111],
      [1755, 3686, 3742, 6602, 6658, 6975, 7046, 10071, 10111, 10202],
      [1755, 6602, 6631, 10202],
      [1755],
      [6602, 6975, 10202],
      [1755, 3686, 3688, 6602, 6658, 6975, 7046, 9715, 10071, 10111, 10202],
      [6602, 6631, 10202],
      [1755, 6975],
      [1090, 1755, 3686, 3688, 6569, 6658, 6975, 7043, 7046, 10202],
      [6602, 6658],
      [1755],
      [1755],
      [6602, 6631, 6658, 6975, 10202],
      [6602, 6658],
      [6602, 10202],
      [995, 1755, 6602, 6658, 6817, 9147],
      [1755, 6569, 6602, 6631, 10202],
      [88, 1755, 6602, 6631, 7046, 10202],
      [1755, 3686, 3688, 6569, 6602, 6631, 6658, 6975, 7046, 9715, 9845, 10202],
      [6658],
      [88, 6602, 6631, 10202],
      [1679, 6538, 6658],
      [88, 1090, 1755, 3686, 6538, 6569, 6602, 6631, 6658, 6975],
      [88, 1755, 6602, 6631, 6658, 6975],
      [6631, 6658, 6975],
      [88, 1755, 2361, 6602, 6631, 6975],
      [88, 1755, 2361, 6602, 6658],
      [88, 1755, 6602, 6631, 6975, 7046, 10202],
      [88, 213, 218, 1090, 1755, 6631, 6975, 7046, 10202],
      [88, 213, 218, 531, 1090, 1675, 1679, 1755, 6631, 6658],
      [88, 1755, 3850],
      [88, 146, 213, 218, 1755, 6631, 6658, 6975, 8769],
      [88, 213, 216, 1755, 6631],
      [1755],
      [87, 88, 213, 218, 1090, 1675, 1679, 1755, 6658, 6975, 8769],
      [88, 1755],
      [88, 1675, 1679, 1755, 6631, 6658, 8769],
      [88, 1090, 6602, 6631, 6975, 10202],
      [88, 1675, 1755, 6602, 6631, 6975],
      [88, 6975, 7046],
      [88, 1675, 6602, 6631, 6658, 6975, 10202],
      [88, 6602, 6975],
      [88, 1755, 6602, 6631],
      [88, 1131, 1132, 1675, 1679, 1755, 1815, 1924, 6631, 7046, 10202],
      [88, 1755, 6602, 6975, 10202],
      [88, 1675, 1755, 6602, 6631, 6975],
      [88, 146, 213, 218, 1675, 1755, 2332, 3850, 6631, 6975, 7046, 8676],
      [88, 1675, 1755, 6602, 6631, 6975, 10071],
      [88, 1675, 1755, 6602, 6631, 6975, 10071],
      [88, 1675, 1755, 6602, 6631, 6975, 7046],
      [88, 1755, 3688, 6975, 8676],
      [88, 1675, 1755, 6602, 6631, 6975, 10071],
      [88, 1755, 6602, 6631, 6975],
      [88, 6602, 6631, 10071],
      [88, 1675, 6602, 6631, 6975],
      [88, 98, 146, 213, 216, 785, 1675, 1679, 6569, 6631, 6658, 6975, 7046, 8676, 9143],
      [88, 1069, 1447, 1675, 1755, 6631, 6975, 8597, 9715],
      [88,
        141,
        146,
        154,
        159,
        162,
        170,
        189,
        190,
        213,
        514,
        531,
        765,
        785,
        815,
        1320,
        1379,
        1447,
        1488,
        1565,
        1661,
        1675,
        1755,
        6602,
        6631,
        6658,
        6877,
        8676,
        9715,
        9872,
        9878,
        9885,
        9889,
        9891,
        10534,],
      [88, 146, 1447, 1675, 1755, 1924, 3850, 6602, 6975, 7046, 9715, 9872, 10071, 10202],
      [88, 146, 189, 216, 220, 531, 1447, 1675, 1679, 3628, 6602, 6631, 6975, 7046, 8676, 9715, 9872, 9891, 10071],
      [88, 98, 146, 1131, 1447, 1675, 1755, 6569, 6602, 6631, 6975, 7046, 8676, 9684, 9715, 9872],
      [88, 146, 189, 531, 1447, 1675, 1755, 3628, 6602, 6631, 6975, 8676, 9715, 9872, 10202],
      [88, 146, 192, 200, 522, 531, 537, 1533, 1553, 1675, 2432, 3628, 6569, 6631, 6975, 7046, 8597, 8676, 9202, 9684, 9714, 9715, 9872, 9891],
      [88, 146, 200, 216, 522, 531, 537, 1447, 1675, 1679, 1755, 6602, 6631, 6975, 8676, 8769, 9684, 9714, 9715, 9872, 9891],
      [88, 1675, 3723, 6631, 6975, 7321, 9162, 9715],
      [88, 146, 494, 1447, 1675, 1755, 3628, 3723, 6602, 6975, 7321, 8676, 9715, 9730],
      [87,
        88,
        141,
        146,
        154,
        159,
        189,
        190,
        192,
        199,
        200,
        212,
        216,
        531,
        536,
        765,
        901,
        1320,
        1447,
        1675,
        1755,
        3628,
        3723,
        5251,
        6602,
        6631,
        6877,
        6975,
        7046,
        7321,
        8597,
        8676,
        9202,
        9684,
        9714,
        9715,
        9723,
        9730,
        9872,
        9885,
        9890,
        10202,],
      [88,
        146,
        189,
        192,
        212,
        216,
        531,
        537,
        765,
        1070,
        1320,
        1447,
        1661,
        1675,
        1755,
        3628,
        3723,
        6602,
        6631,
        6658,
        6975,
        7046,
        8597,
        8676,
        9202,
        9715,
        9723,
        9728,
        9730,
        9872,
        9891,
        10202,],
      [88,
        146,
        159,
        189,
        212,
        213,
        531,
        536,
        765,
        1070,
        1320,
        1447,
        1565,
        1661,
        1675,
        1755,
        3628,
        3688,
        3723,
        3850,
        6602,
        6631,
        6658,
        6868,
        6877,
        6975,
        7046,
        7066,
        7321,
        8596,
        8597,
        8676,
        9162,
        9202,
        9714,
        9715,
        9723,
        9728,
        9730,
        9872,
        9891,
        10202,],
      [88,
        146,
        189,
        212,
        224,
        531,
        536,
        765,
        1320,
        1447,
        1661,
        1675,
        1755,
        3628,
        3723,
        3850,
        6602,
        6631,
        6877,
        8597,
        8676,
        9202,
        9715,
        9730,
        9872,
        9891,
        10202,],
      [88,
        98,
        146,
        170,
        189,
        192,
        212,
        531,
        894,
        1090,
        1320,
        1348,
        1447,
        1675,
        1755,
        3323,
        3628,
        3723,
        3840,
        6602,
        6631,
        6658,
        6877,
        6897,
        6975,
        7066,
        8676,
        9714,
        9715,
        9723,
        9730,
        9872,
        9891,
        10202,],
      [88,
        130,
        146,
        1447,
        1533,
        1675,
        1755,
        1924,
        3628,
        3686,
        3723,
        5251,
        6312,
        6569,
        6631,
        6975,
        7046,
        7066,
        7096,
        7321,
        8596,
        8597,
        8676,
        9162,
        9199,
        9202,
        9685,
        9715,
        9723,
        9730,
        9732,
        9872,
        9891,
        9921,],
      [88,
        146,
        189,
        212,
        216,
        536,
        1127,
        1661,
        1675,
        1755,
        3628,
        6602,
        6631,
        6658,
        6877,
        6975,
        8676,
        9685,
        9728,
        9730,
        9872,
        9891,
        9921,
        10202,],
      [88,
        130,
        146,
        189,
        212,
        216,
        494,
        531,
        536,
        1070,
        1320,
        1447,
        1661,
        1675,
        1755,
        6602,
        6631,
        6897,
        6975,
        7321,
        8676,
        9156,
        9202,
        9685,
        9715,
        9723,
        9728,
        9730,
        9731,
        9872,
        9891,],
      [88, 146, 531, 1675, 1755, 6631, 8676, 9685, 9872, 9891],
      [88,
        146,
        159,
        189,
        192,
        216,
        531,
        1070,
        1559,
        1661,
        1675,
        1755,
        6602,
        6631,
        6877,
        6897,
        6975,
        7046,
        8676,
        9685,
        9723,
        9728,
        9730,
        9872,
        9885,
        9891,
        10202,],
      [88,
        98,
        146,
        189,
        212,
        216,
        224,
        531,
        536,
        1127,
        1447,
        1675,
        1755,
        1924,
        3628,
        5240,
        6602,
        6631,
        6658,
        6975,
        7321,
        8594,
        8676,
        9685,
        9686,
        9715,
        9723,
        9728,
        9730,
        9731,
        9732,
        9872,
        9878,
        9885,
        9891,
        10202,],
      [88, 146, 189, 216, 531, 1320, 1447, 1661, 9685, 9723, 9728, 9730, 9872],
      [83,
        88,
        138,
        146,
        159,
        189,
        190,
        212,
        216,
        531,
        785,
        1320,
        1447,
        1559,
        1661,
        1675,
        1755,
        1924,
        6602,
        6631,
        6868,
        6877,
        6897,
        6975,
        7096,
        8594,
        8596,
        8676,
        9162,
        9195,
        9197,
        9199,
        9202,
        9685,
        9686,
        9723,
        9728,
        9730,
        9732,
        9872,
        9878,
        9885,
        9891,
        10202,],
      [88,
        146,
        154,
        170,
        189,
        190,
        200,
        216,
        224,
        536,
        1070,
        1320,
        1447,
        1513,
        1559,
        1569,
        1661,
        1675,
        1924,
        3323,
        3686,
        3688,
        5396,
        6569,
        6602,
        6631,
        6877,
        6897,
        6975,
        7101,
        7321,
        8596,
        8597,
        8676,
        9162,
        9199,
        9202,
        9685,
        9686,
        9723,
        9728,
        9730,
        9732,
        9872,
        9885,
        9891,
        9952,
        10202,],
      [88, 130, 146, 154, 189, 216, 531, 1127, 1447, 1675, 6602, 6631, 6877, 6897, 6975, 7046, 8676, 9199, 9685, 9723, 9728, 9872, 10121],
      [88,
        146,
        494,
        1127,
        1447,
        1661,
        1675,
        1755,
        6569,
        6602,
        6631,
        6897,
        6975,
        7066,
        7085,
        8596,
        8676,
        9149,
        9186,
        9192,
        9199,
        9202,
        9685,
        9686,
        9720,
        9722,
        9723,
        9730,
        9731,
        9872,
        10121,
        10202,],
      [88,
        146,
        189,
        212,
        216,
        531,
        1320,
        1559,
        1661,
        1675,
        3686,
        5240,
        6569,
        6631,
        6877,
        6975,
        7046,
        8676,
        9202,
        9685,
        9686,
        9723,
        9728,
        9730,
        9872,
        9891,
        10121,],
      [88,
        146,
        189,
        216,
        531,
        901,
        1447,
        1559,
        1661,
        1675,
        1711,
        3686,
        5240,
        6602,
        6631,
        6877,
        6889,
        6897,
        6928,
        8676,
        9199,
        9685,
        9686,
        9723,
        9730,
        9872,
        9878,
        9891,
        9921,
        10121,
        10202,],
      [88, 146, 189, 531, 1320, 1675, 1755, 5240, 6631, 6877, 6975, 8676, 9199, 9728, 9730, 9872, 9891, 10121],
      [88,
        130,
        146,
        189,
        216,
        531,
        785,
        894,
        1320,
        1447,
        1561,
        1661,
        1675,
        1711,
        5240,
        6569,
        6631,
        6877,
        6897,
        6975,
        7046,
        8596,
        8676,
        9152,
        9156,
        9161,
        9165,
        9186,
        9194,
        9197,
        9199,
        9215,
        9242,
        9685,
        9686,
        9723,
        9728,
        9730,
        9732,
        9872,
        9885,
        9891,
        9952,
        10121,],
      [83,
        88,
        98,
        138,
        146,
        154,
        159,
        170,
        189,
        190,
        192,
        200,
        216,
        514,
        1131,
        1263,
        1320,
        1438,
        1447,
        1488,
        1489,
        1501,
        1508,
        1513,
        1514,
        1516,
        1517,
        1519,
        1533,
        1555,
        1559,
        1568,
        1569,
        1661,
        1675,
        1713,
        1755,
        1924,
        3850,
        5359,
        5397,
        6602,
        6868,
        6877,
        6889,
        6897,
        7098,
        7101,
        7321,
        8676,
        8769,
        9179,
        9186,
        9192,
        9195,
        9199,
        9202,
        9243,
        9685,
        9686,
        9720,
        9728,
        9730,
        9732,
        9871,
        9872,
        9878,
        9885,
        9891,
        9921,
        10534,],
      [88,
        146,
        159,
        189,
        216,
        224,
        494,
        537,
        1070,
        1127,
        1131,
        1320,
        1447,
        1755,
        6602,
        6631,
        6658,
        6877,
        6889,
        6975,
        7085,
        8676,
        9195,
        9685,
        9686,
        9730,
        9872,
        9885,
        9891,
        10121,],
      [88, 1447, 1675, 6602, 6631, 6658, 6975, 7046, 8676, 9685, 9686, 9730, 9872, 9891, 10121, 10202],
      [88, 146, 537, 1320, 1447, 1675, 1755, 6569, 6602, 6631, 6877, 6889, 6975, 9179, 9685, 9686, 9872, 9885, 9891, 10121, 10202],
      [88, 146, 1447, 1661, 1675, 1755, 1924, 5240, 6602, 6631, 6877, 6897, 6975, 7046, 8676, 8769, 9179, 9685, 9730, 9872, 9921, 10121, 10202],
      [88,
        146,
        517,
        1661,
        1924,
        3628,
        3688,
        5240,
        5251,
        5397,
        6318,
        6569,
        6631,
        6877,
        6897,
        6975,
        8676,
        8692,
        9149,
        9162,
        9172,
        9179,
        9186,
        9195,
        9196,
        9685,
        9693,
        9723,
        9730,
        9872,
        9878,
        9921,
        10072,
        10121,],
      [83,
        88,
        154,
        159,
        894,
        1447,
        1713,
        1924,
        3628,
        5251,
        6318,
        6631,
        6897,
        8676,
        9149,
        9195,
        9196,
        9730,
        9872,
        9891,
        9921,
        9952,
        10121,
        10202,],
      [88,
        138,
        146,
        159,
        216,
        765,
        785,
        1447,
        1661,
        1675,
        1755,
        3686,
        5226,
        5240,
        6316,
        6318,
        6631,
        6658,
        6868,
        6877,
        6897,
        6975,
        8570,
        8692,
        9179,
        9186,
        9195,
        9685,
        9686,
        9728,
        9730,
        9872,
        9891,
        9952,
        10121,
        10202,],
      [88, 146, 189, 1090, 1320, 1447, 1675, 1755, 6316, 6631, 6877, 8676, 9128, 9195, 9685, 9686, 9728, 9730, 9872, 9885, 9891, 10121, 10202],
      [88,
        130,
        146,
        216,
        1127,
        1559,
        1675,
        1755,
        2643,
        2951,
        3628,
        3688,
        5240,
        5251,
        5359,
        6316,
        6318,
        6569,
        6631,
        6658,
        6877,
        6928,
        6975,
        7046,
        7098,
        7101,
        8676,
        9128,
        9179,
        9195,
        9685,
        9686,
        9728,
        9730,
        9865,
        9872,
        10121,
        10202,],
      [88,
        146,
        154,
        159,
        170,
        189,
        190,
        192,
        213,
        224,
        544,
        765,
        785,
        796,
        825,
        851,
        1131,
        1229,
        1263,
        1320,
        1348,
        1379,
        1447,
        1533,
        1555,
        1568,
        1661,
        1675,
        1711,
        1713,
        1755,
        1924,
        3840,
        3850,
        5237,
        5240,
        5359,
        5397,
        6316,
        6318,
        6602,
        6631,
        6658,
        6868,
        6877,
        6889,
        6897,
        7098,
        7101,
        8593,
        8676,
        9162,
        9179,
        9195,
        9685,
        9686,
        9723,
        9728,
        9730,
        9872,
        9878,
        9885,
        9891,
        9921,
        9952,
        10121,
        10534,],
      [88, 146, 189, 216, 531, 1127, 1320, 1447, 1755, 6631, 6877, 6897, 6975, 8676, 8769, 9195, 9685, 9686, 9728, 9730, 9872, 9891],
      [88,
        146,
        159,
        189,
        1127,
        1447,
        1533,
        1559,
        1675,
        1755,
        1815,
        1924,
        3723,
        5240,
        6318,
        6569,
        6602,
        6631,
        6868,
        6877,
        6897,
        6975,
        8593,
        8676,
        8692,
        8769,
        9128,
        9195,
        9196,
        9686,
        9728,
        9730,
        9872,
        10121,],
      [88, 146, 1675, 6631, 6877, 8676, 9195, 9686, 9730, 9872, 9891, 10202],
      [88,
        146,
        1123,
        1447,
        1559,
        1675,
        1755,
        3688,
        3850,
        5220,
        5226,
        5237,
        5240,
        5359,
        5397,
        6318,
        6569,
        6602,
        6631,
        6877,
        6897,
        6975,
        7085,
        8593,
        8676,
        8692,
        8769,
        9128,
        9149,
        9156,
        9186,
        9196,
        9685,
        9686,
        9728,
        9730,
        9851,
        9872,
        9891,
        9952,
        10115,
        10202,],
      [88,
        146,
        154,
        544,
        785,
        894,
        1090,
        1131,
        1447,
        1675,
        1724,
        1755,
        2643,
        5240,
        5251,
        5397,
        6318,
        6631,
        6658,
        6877,
        6897,
        8676,
        9128,
        9186,
        9195,
        9730,
        9872,
        9891,
        9933,
        9952,
        10121,
        10202,],
      [88, 785, 1675, 1755, 6569, 6631, 6658, 8676, 8769, 9872, 9891, 10202],
      [88, 146, 1447, 6602, 6975, 8676, 8769, 9685, 10202],
      [88,
        146,
        189,
        216,
        537,
        1263,
        1320,
        1447,
        1675,
        1755,
        3686,
        6602,
        6631,
        6877,
        6889,
        6897,
        6975,
        7101,
        8676,
        9186,
        9195,
        9685,
        9686,
        9728,
        9730,
        9872,
        9878,
        9885,
        9891,
        10121,
        10202,],
      [1127, 1755, 6602, 6631, 8769, 9872, 9891, 10202],
      [88, 130, 146, 216, 531, 1320, 1675, 1755, 6868, 6877, 6975, 8676, 9195, 9685, 9728, 9730, 9872, 9885, 9891],
      [88,
        146,
        1675,
        3323,
        5226,
        5240,
        5397,
        6318,
        6631,
        6658,
        6897,
        6928,
        6975,
        8593,
        8676,
        8692,
        9128,
        9179,
        9186,
        9195,
        9196,
        9685,
        9686,
        9728,
        9730,
        9865,
        9871,
        9872,
        9878,
        9891,
        9952,
        10071,
        10121,],
      [88,
        146,
        159,
        189,
        190,
        212,
        216,
        494,
        1127,
        1533,
        1675,
        1755,
        1924,
        3688,
        6631,
        6658,
        6868,
        6975,
        8676,
        8692,
        9195,
        9686,
        9730,
        9872,
        9878,
        9891,
        10121,],
      [2643, 6631, 6877, 9195, 9685, 9686, 9730, 9872, 10121],
      [88, 1755, 2643, 6631, 6877, 8769, 9685, 9686, 9730, 9872, 9891, 10121, 10202],
      [88, 130, 146, 189, 1320, 1559, 5397, 6631, 6877, 6897, 8676, 8692, 8769, 9128, 9179, 9195, 9685, 9730, 9872, 9878, 10121],
      [894,
        1127,
        1131,
        1755,
        3840,
        5237,
        6318,
        6631,
        6658,
        8570,
        8676,
        9128,
        9149,
        9195,
        9196,
        9685,
        9686,
        9723,
        9727,
        9728,
        9730,
        9872,
        9878,
        9891,
        10121,],
      [88, 146, 531, 1263, 1320, 1755, 1924, 2643, 6631, 6868, 6975, 9128, 9179, 9195, 9686, 9730, 9872, 10072, 10121, 10202],
      [1675, 1755, 2643, 10202],
      [88, 3686, 6631, 6877, 8676, 8769, 9195, 9686, 9730, 9891, 10121, 10202],
      [88, 1675, 1755, 2643, 6631, 6658, 10202],
      [88, 1675, 1755, 6631, 10202],
      [785, 1675, 1755, 2643, 6602, 6631, 6877, 8676, 9730, 9891, 10202],
      [88, 1181, 1229, 1533, 1675, 1755, 2556, 6631, 6658, 7098, 9685, 9730, 9872, 9891, 10202],
      [88, 146, 159, 189, 785, 1447, 1675, 1755, 6602, 6631, 8676, 9179, 9195, 9685, 9686, 9730, 9872, 9878, 9891, 10202],
      [1675, 1755, 6631, 9685, 9730, 10202],
      [1675, 1755, 6631, 10202],
      [1755, 6602, 8676, 9891],
      [1755, 8676, 9891, 10121],
      [1675, 1755, 6631, 8676, 9685, 9891, 10121, 10202],
      [88, 146, 785, 901, 1090, 1675, 1755, 2556, 6602, 6631, 6658, 6877, 6897, 8593, 8676, 9196, 9685, 9723, 9730, 9872, 9891, 10121, 10202],
      [522,
        894,
        1090,
        2556,
        3628,
        3723,
        3742,
        5240,
        6318,
        6569,
        6631,
        6877,
        6897,
        6975,
        7043,
        9128,
        9149,
        9156,
        9165,
        9186,
        9190,
        9192,
        9194,
        9196,
        9723,],
      [1533, 2556, 6318, 6658, 9723],
      [88, 1127, 1675, 1755, 6569, 6631, 8676, 9730, 9872],
      [88, 785, 1447, 1675, 1755, 6602, 6631, 6658, 9730, 9891, 10202],
      [88,
        1070,
        1447,
        1675,
        1755,
        1924,
        3688,
        5226,
        5240,
        5359,
        6308,
        6318,
        6569,
        6631,
        6897,
        6975,
        7046,
        8676,
        9128,
        9179,
        9195,
        9685,
        9686,
        9730,
        9826,
        9865,
        9872,
        9878,
        9952,
        10121,],
      [88, 146, 1675, 1755, 6631, 9685, 9730, 9872, 9891, 10202],
      [1755, 10121, 10202],
      [130, 785, 1675, 6877, 8676, 9128, 9685, 9730, 9872, 9891, 10121],
      [88, 785, 1675, 1755, 6631, 6658, 8676, 9872, 10202],
      [88, 785, 1127, 1675, 1755, 6631, 6897, 9730, 9872, 9891, 10121, 10202],
      [88, 146, 1127, 1447, 1675, 1755, 6631, 9685, 9730, 9872, 9891, 10121, 10202],
      [88,
        130,
        146,
        159,
        189,
        216,
        785,
        1127,
        1559,
        1565,
        1569,
        1675,
        1755,
        1924,
        3850,
        6602,
        6658,
        6868,
        6877,
        6975,
        8676,
        9685,
        9686,
        9730,
        9872,
        9891,
        10121,
        10202,],
      [1675, 1755, 6631, 6975, 9730, 9872, 9891, 10121],
      [88, 9730, 9872, 10121],
      [88, 785, 894, 1675, 6631, 6658, 6897, 6975, 8676, 9685, 9723, 9730, 9872, 10121, 10202],
      [785, 1675, 10202],
      [146, 785, 1675, 1755, 6631, 6658, 6975, 9730, 9872, 10121],
      [88,
        130,
        146,
        170,
        190,
        216,
        785,
        1070,
        1447,
        1559,
        1565,
        1569,
        1924,
        3323,
        5396,
        5397,
        6631,
        6897,
        6975,
        8676,
        8692,
        9128,
        9195,
        9685,
        9686,
        9730,
        9878,
        9891,
        10072,
        10121,],
      [146, 1127, 1675, 1755, 6631, 9891],
      [146,
        154,
        815,
        1131,
        1447,
        1533,
        1675,
        1924,
        2361,
        5397,
        6631,
        6897,
        7098,
        7101,
        8676,
        8769,
        9179,
        9195,
        9686,
        9728,
        9730,
        9872,
        9878,
        10534,],
      [146, 785, 1755, 6631, 6868, 8676, 9685, 9872],
      [88, 1320, 1447, 1675, 1924, 2643, 6631, 6877, 6897, 6975, 8692, 9730, 9872, 9891, 10121],
      [88, 146, 1675, 1755, 6631],
      [146, 1675, 1755, 6631, 6975, 10202],
      [146, 1675, 1755, 6631, 8676, 10202],
      [146, 1675, 1755, 6631],
      [146, 785, 1675, 1755, 6631, 6975, 10202],
      [146, 189, 216, 765, 785, 1447, 1675, 6631, 6868, 9730, 9872, 10121],
      [130, 146, 189, 216, 1070, 1675, 3686, 6868, 6975, 8676, 9128, 9685, 9872, 10121],
      [88, 1675, 1755, 6631, 6658],
      [88, 1675, 6631, 10202],
      [88, 146, 154, 159, 189, 1559, 1565, 1675, 1755, 6602, 6631, 6658, 6975, 9128, 9195, 9686, 10121],
      [88, 130, 146, 216, 1070, 1447, 1675, 1755, 6631, 6868, 6897, 6975, 9872, 9891, 10121, 10202],
      [88, 1675, 1755, 6631, 10202],
      [88,
        146,
        216,
        785,
        1070,
        1123,
        1127,
        1661,
        1675,
        1755,
        3686,
        3688,
        5251,
        5359,
        6318,
        6868,
        6975,
        7046,
        7085,
        8692,
        9128,
        9195,
        9730,
        9851,
        9865,
        9872,
        10121,],
      [146, 765, 785, 1070, 1561, 1675, 3323, 3688, 5251, 5359, 6318, 6631, 6975, 7046, 9128, 9186, 9195, 9730, 9851, 9872, 10121],
      [785, 894, 1675, 3688, 5251, 6318, 6569, 6631, 6975, 9156, 9186, 9196, 9242, 9730, 9891],
      [88, 765, 1675, 1755, 6631, 10202],
      [130, 146, 216, 531, 765, 1675, 1755, 6631, 10202],
      [785, 1675, 6631],
      [130, 146, 216, 1675, 6631],
      [130, 146, 216, 531, 785, 3850, 5240, 5251, 5397, 6897, 6975, 8676, 8692, 9128, 9195, 9686, 9730, 10121],
      [146, 189, 531, 785, 1569, 1675, 1755, 6602, 6631, 6975, 9128, 9156, 9179, 9195, 9685],
      [88, 146, 189, 785, 1569, 1661, 1675, 1711, 8676, 9179],
      [88, 146, 785, 1070, 1559, 1675, 2951, 3686, 3688, 6318, 6631, 6975, 7046, 9156, 9186, 9685, 10121],
      [1675, 6975, 9152, 9186, 9195, 10202],
      [146, 1675, 1755, 6631, 6975, 10202],
      [494, 1661, 1755],
      [88,
        141,
        146,
        154,
        170,
        1090,
        1131,
        1393,
        1438,
        1447,
        1501,
        1533,
        1555,
        1565,
        1569,
        1675,
        1713,
        1924,
        3840,
        5251,
        6658,
        6889,
        6897,
        9730,
        9871,
        9872,
        9878,
        9885,
        9891,
        10121,
        10534,],
      [88, 130, 146, 216, 785, 1675, 2951, 3686, 3688, 5220, 5240, 6318, 6975, 7046, 9156, 9161, 9162, 9165, 9186, 9192, 9195, 9197, 10121],
      [88, 130, 146, 216, 1070, 1675, 2517, 6602],
      [88, 130, 146, 216, 1675],
      [1675, 1755, 3688, 6318, 6631, 6975, 7043, 7046, 9152, 9156, 9161, 9165, 9186, 9190, 9192, 9194, 9197, 9215, 9243, 9685, 10121, 10202],
      [146,
        189,
        765,
        785,
        1565,
        1569,
        1661,
        1675,
        5240,
        6602,
        6631,
        6975,
        7043,
        8692,
        9128,
        9179,
        9186,
        9188,
        9195,
        9196,
        9199,
        9202,
        9686,
        10121,],
      [88,
        130,
        146,
        216,
        1070,
        1127,
        1263,
        1675,
        3686,
        5220,
        5226,
        6318,
        6631,
        6658,
        6975,
        7043,
        7046,
        8692,
        9149,
        9156,
        9186,
        9192,
        9195,
        9196,
        10121,],
      [88, 146, 159, 189, 785, 815, 1559, 1661, 1675, 1755, 1924, 6602, 6631, 6897, 9152, 9186, 9686, 10121],
      [1675, 10202],
      [88,
        130,
        146,
        154,
        189,
        531,
        765,
        785,
        815,
        901,
        1070,
        1127,
        1561,
        1565,
        1661,
        1675,
        1755,
        1924,
        3323,
        3686,
        3688,
        5240,
        6315,
        6316,
        6318,
        6602,
        6631,
        6658,
        6897,
        6975,
        7046,
        7085,
        8596,
        8676,
        8692,
        9128,
        9152,
        9156,
        9186,
        9188,
        9192,
        9193,
        9195,
        9197,
        9243,
        9723,
        9851,
        10072,
        10121,],
      [146, 825, 1675],
      [146, 216, 531, 1070, 1675, 6312, 6318, 6631, 6975, 9128, 9197, 9728, 10121],
      [146, 216, 531, 1675],
      [88, 146, 531, 1661, 3323, 5251, 6975],
      [1675, 3686, 6569, 6631, 6975, 7046, 10121],
      [83,
        84,
        88,
        130,
        138,
        146,
        154,
        216,
        224,
        531,
        765,
        785,
        796,
        1320,
        1348,
        1447,
        1516,
        1533,
        1569,
        1675,
        1924,
        2517,
        6631,
        6658,
        6897,
        6975,
        7101,
        8692,
        8769,
        9156,
        9161,
        9165,
        9179,
        9186,
        9192,
        9197,
        9243,
        9723,
        9730,
        9732,
        9872,
        9890,
        9891,
        10202,],
      [88, 130, 146, 216, 531, 894, 1070, 1127, 1675, 1755, 6569, 6631, 6658, 6975, 7046, 8676, 9128, 9723, 9728, 10121],
    ]
    result = @contest.run_on(obs)

    assert_equal 9, result.size
  end
end
