require 'test_helper'

class Interp2dTest < GSL::TestCase

  def saddle(x,y)
    x*x - y*y
  end

  def test_saddle_interpolation
    x_samples =(-20..20).map(&:to_f).to_a
    y_samples = (-20..20).map(&:to_f).to_a
    z_samples = []
    x_samples.each do |x|
      y_samples.each do |y|
        z_samples << saddle(x,y)
      end
    end

    x_array = GSL::Vector.alloc(x_samples)
    y_array = GSL::Vector.alloc(y_samples)
    z_array = GSL::Vector.alloc(z_samples)

    tolerance = 0.05 # 5% inaccuracy is tolerated in tests below
    interpolator_type = GSL::Interp2d::BICUBIC

    i2d = GSL::Interp2d.alloc(interpolator_type, x_array, y_array, z_array)

    # confirm that the fit passes very close to the sampled data points
    x_samples.each do |x|
      y_samples.each do |y|
        expected_z = saddle(x,y)
        z = i2d.eval(x,y)
        error = (z - expected_z).abs
        max_error = (expected_z.abs)*tolerance
        if max_error == 0
          max_error = tolerance
        end
        refute error > max_error, "error @ sample #{x},#{y}"
      end
    end

    interstitial_x_values = x_samples.first(x_samples.size-1).map {|v| v+ 0.5}
    interstitial_y_values = y_samples.first(x_samples.size-1).map {|v| v+ 0.3}
    # confirm that interstitial values are interpolated accurately 
    interstitial_x_values.each do |x|
      interstitial_y_values.each do |y|
        expected_z = saddle(x,y)
        z = i2d.eval(x,y)
        error = (z - expected_z).abs
        max_error = (expected_z.abs)*tolerance
        if max_error == 0
          max_error = tolerance
        end
        refute error > max_error, "error @ interstitial #{x},#{y}"
      end
    end

  end

end
