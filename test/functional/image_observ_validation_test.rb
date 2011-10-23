require 'test_helper'

class ImageObservValidationTest < ActionController::TestCase

  tests ImagesController

  setup do
    @obs = FactoryGirl.create(:observation)
    @image = FactoryGirl.create(:image, :observations => [@obs])
  end

  test "should not update image with empty observation list" do
    login_as_admin
    new_attr = @image.attributes.dup
    new_attr['code'] = 'new_img_code'
    new_attr[:observation_ids] = []
    put :update, :id => @image.to_param, :image => new_attr
    assigns(:image).errors.should_not be_blank
    assert_template :edit
  end

  test "should not update image if no observation list provided" do
    login_as_admin
    new_attr = @image.attributes.dup # observations_ids are not in here
    new_attr['code'] = 'new_img_code'
    put :update, :id => @image.to_param, :image => new_attr
    assigns(:image).errors.should_not be_blank
    assert_template :edit
  end

  test "should restore observation list if image was not saved due to its emptiness" do
    login_as_admin
    new_attr = @image.attributes.dup # observations_ids are not in here
    new_attr['code'] = 'new_img_code'
    new_attr[:observation_ids] = []
    put :update, :id => @image.to_param, :image => new_attr
    assigns(:image).observation_ids.should == @image.observation_ids
  end

  test "should not restore former observation list if image was not saved not due to their emptiness" do
    login_as_admin
    new_attr = @image.attributes.dup # observations_ids are not in here
    new_attr['code'] = ''
    new_attr[:observation_ids] = [new_obs = FactoryGirl.create(:observation)]
    put :update, :id => @image.to_param, :image => new_attr
    assigns(:image).observation_ids.should == [new_obs.id]
  end

  test 'should exclude duplicated observations on image create' do
    login_as_admin
    new_attr = @image.attributes.dup
    new_attr[:observation_ids] = [@obs.id, @obs.id]
    new_attr['code'] = 'new_img_code'
    assert_difference('Image.count') do
      assert_nothing_raised { post :create, :image => new_attr }
    end
    assigns(:image).errors.should be_empty
    assigns(:image).observation_ids.should == [@obs.id]
  end

  test 'should exclude duplicated observation (existing) on image update' do
    login_as_admin
    new_attr = @image.attributes.dup
    obs = FactoryGirl.create(:observation)
    new_attr[:observation_ids] = [@obs.id, @obs.id, obs.id]
    assert_nothing_raised do
      put :update, :id => @image.to_param, :image => new_attr
    end
    assigns(:image).errors.should be_empty
    assigns(:image).observation_ids.count.should == 2
  end

  test 'should exclude duplicated observation (new) on image update' do
    login_as_admin
    new_attr = @image.attributes.dup
    obs = FactoryGirl.create(:observation)
    new_attr[:observation_ids] = [@obs.id, obs.id, obs.id]
    assert_nothing_raised do
      put :update, :id => @image.to_param, :image => new_attr
    end
    assigns(:image).errors.should be_empty
    assigns(:image).observation_ids.count.should == 2
  end

  test 'should not create image with inconsistent observations (different date)' do
    login_as_admin
    obs1 = FactoryGirl.create(:observation, :observ_date => '2011-01-01')
    obs2 = FactoryGirl.create(:observation, :observ_date => '2010-01-01')
    new_attr = FactoryGirl.attributes_for(:image, :code => 'newimg', :observation_ids => [obs1.id, obs2.id])
    assert_difference('Image.count', 0) do
      post :create, :image => new_attr
    end
    assigns(:image).errors.should_not be_empty
  end

  test 'should not create image with inconsistent observations (different loc)' do
    login_as_admin
    obs1 = FactoryGirl.create(:observation, :locus => seed(:kiev))
    obs2 = FactoryGirl.create(:observation, :locus => seed(:krym))
    new_attr = FactoryGirl.attributes_for(:image, :code => 'newimg', :observation_ids => [obs1.id, obs2.id])
    assert_difference('Image.count', 0) do
      post :create, :image => new_attr
    end
    assigns(:image).errors.should_not be_empty
  end

  test 'should not update image with inconsistent observations' do
    login_as_admin
    obs1 = FactoryGirl.create(:observation, :observ_date => '2011-01-01')
    obs2 = FactoryGirl.create(:observation, :observ_date => '2010-01-01')
    new_attr = @image.attributes.merge(:observation_ids => [obs1.id, obs2.id])
    put :update, :id => @image.to_param, :image => new_attr
    assigns(:image).errors.should_not be_empty
  end

  test 'should preserve changed values if image failed to update with inconsistent observations' do
    login_as_admin
    obs1 = FactoryGirl.create(:observation, :observ_date => '2011-01-01')
    obs2 = FactoryGirl.create(:observation, :observ_date => '2010-01-01')
    new_attr = @image.attributes.merge(:observation_ids => [obs1.id, obs2.id], :code => 'newcode')
    put :update, :id => @image.to_param, :image => new_attr
    assigns(:image).code.should == new_attr[:code]
  end

end
