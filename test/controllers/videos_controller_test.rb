# frozen_string_literal: true

require "test_helper"

class VideosControllerTest < ActionController::TestCase
  setup do
    @video = create(:video)
    @obs = @video.observations.first
  end

  test "get index" do
    get :index
    assert_response :success
    assert_not_empty assigns(:videos)

    assert_select "a[href='#{video_path(@video)}']"
  end

  test "crazy page number should return 404" do
    assert_raise ActiveRecord::RecordNotFound do
      get :index, params: {page: 7262}
    end
  end

  # test "show videos of multiple species" do
  #   sp1 = species(:saxola)
  #   sp2 = species(:jyntor)
  #   card = create(:card, observ_date: "2008-07-01")
  #   obs1 = create(:observation, species: sp1, card: card)
  #   obs2 = create(:observation, species: sp2, card: card)
  #   video = create(:video, slug: 'picture-of-the-shrike-and-the-wryneck', observations: [obs1, obs2])
  #
  #   get :multiple_species
  #   assert_response :success
  #   assert_not_empty assigns(:videos)
  #
  #   assert_select "a[href=#{video_path(video)}]"
  # end

  test "get new" do
    login_as_admin
    get :new
    assert_response :success
  end

  # test "get observations for an video" do
  #   login_as_admin
  #   get :observations, id: @video.id, format: :json
  #   assert_response :success
  #   assert_equal Mime[:json], response.media_type
  # end

  test "create video with one observation" do
    login_as_admin
    new_attr = attributes_for(:video, slug: "new_video_slug").except(:observations)
    assert_difference("Video.count") do
      post :create, params: {video: new_attr, obs: [@obs.id]}
    end

    assert_redirected_to edit_map_video_path(assigns(:video))
  end

  test "create video with several observations" do
    login_as_admin
    obs2 = create(:observation, taxon: taxa(:pasdom), card: @obs.card)
    obs3 = create(:observation, taxon: taxa(:hirrus), card: @obs.card)
    new_attr = attributes_for(:video, slug: "new_video_slug").except(:observations)
    assert_difference("Video.count") do
      post :create, params: {video: new_attr, obs: [@obs.id, obs2.id, obs3.id]}
      video = assigns(:video)
      assert_empty video.errors
    end
    assert_redirected_to edit_map_video_path(assigns(:video))
  end

  test "do not save video without slug" do
    login_as_admin
    new_attr = attributes_for(:video, slug: "")
    assert_difference("Video.count", 0) do
      post :create, params: {video: new_attr, obs: [@obs.id]}
    end

    assert_template :form
  end

  test "do not save video with no observations" do
    login_as_admin
    new_attr = attributes_for(:video, slug: "new_video_slug")
    assert_difference("Video.count", 0) do
      post :create, params: {video: new_attr, obs: []}
    end

    assert_template :form
  end

  test "do not save video with conflicting observations" do
    login_as_admin
    obs2 = create(:observation, card: create(:card, locus: loci(:kyiv)))
    obs3 = create(:observation, card: create(:card, locus: loci(:brovary)))
    new_attr = attributes_for(:video, slug: "new_video_slug")
    assert_difference("Video.count", 0) do
      post :create, params: {video: new_attr, obs: [obs2.id, obs3.id]}
    end

    assert_template :form
  end

  test "show video" do
    get :show, params: {id: @video.to_param}
    assert_response :success
  end

  test "show: invalid video slug should return 404" do
    assert_raise ActiveRecord::RecordNotFound do
      get :show, params: {id: "zzzzz"}
    end
  end

  test "get edit" do
    login_as_admin
    get :edit, params: {id: @video.to_param}
    assert_response :success
  end

  test "get map_edit" do
    login_as_admin
    get :map_edit, params: {id: @video.to_param}
    assert_response :success
  end

  test "update video" do
    login_as_admin
    new_attr = @video.attributes
    new_attr["slug"] = "new_slug"
    put :update, params: {id: @video.to_param, video: new_attr, obs: @video.observation_ids}
    assert_redirected_to edit_map_video_path(assigns(:video))
  end

  test "remove spot_id when changing video observation" do
    login_as_admin
    spot = create(:spot, observation_id: @video.observation_ids.first)
    @video.spot_id = spot.id
    @video.save!
    new_attr = @video.attributes
    obs = create(:observation)
    put :update, params: {id: @video.to_param, video: new_attr, obs: [obs.id]}
    @video.reload
    assert_not @video.spot_id, "Spot id should be nil"
  end

  test "do not remove spot_id when resaving video" do
    login_as_admin
    spot = create(:spot, observation_id: @video.observation_ids.first)
    @video.spot_id = spot.id
    @video.save!
    new_attr = @video.attributes
    put :update, params: {id: @video.to_param, video: new_attr, obs: @video.observation_ids}
    @video.reload
    assert @video.spot_id, "Spot id is nil"
  end

  test "do not remove spot_id when adding video observation" do
    login_as_admin
    spot = create(:spot, observation_id: @video.observation_ids.first)
    @video.spot_id = spot.id
    @video.save!
    new_attr = @video.attributes
    obs = create(:observation, card: @obs.card)
    put :update, params: {id: @video.to_param, video: new_attr, obs: @video.observation_ids.push(obs.id)}
    assert assigns(:video).errors.blank?
    @video.reload
    assert @video.spot_id, "Spot id is nil"
  end

  test "do not remove spot_id when video change is not valid" do
    login_as_admin
    spot = create(:spot, observation_id: @video.observation_ids.first)
    @video.spot_id = spot.id
    @video.save!
    new_attr = @video.attributes
    obs1 = create(:observation)
    obs2 = create(:observation)
    put :update, params: {id: @video.to_param, video: new_attr, obs: [obs1.id, obs2.id]}
    assert assigns(:video).errors.present?
    @video.reload
    assert @video.spot_id, "Spot id is nil"
  end

  test "update video spot via json" do
    spot = create(:spot)
    obs = spot.observation
    video = create(:video, observation_ids: [obs.id], spot: spot)
    spot2 = create(:spot, observation: obs)
    login_as_admin
    post :patch, params: {id: video.to_param, video: {spot_id: spot2.id}}, format: :json
    video.reload
    assert_equal spot2.id, video.spot_id
    assert_response :no_content
  end

  test "destroy video" do
    login_as_admin
    assert_difference("Video.count", -1) do
      delete :destroy, params: {id: @video.to_param}
    end

    assert_redirected_to videos_path
  end

  # test 'do not show link to private post to public user on video page' do
  #   blogpost = create(:post, status: 'PRIV')
  #   @obs.post = blogpost
  #   @obs.save!
  #   get :show, id: @video
  #   assert_select "a[href=#{public_post_path(blogpost)}]", false
  # end

  # test 'show link to public post to public user on video page' do
  #   blogpost = create(:post)
  #   @obs.post = blogpost
  #   @obs.save!
  #   get :show, id: @video.to_param
  #   assert_select "a[href=#{public_post_path(blogpost)}]"
  # end
end
