# frozen_string_literal: true

class BlogController < ApplicationController
  before_action only: [:home, :year, :month] do
    @feed = "blog"
  end

  localized only: [:home, :archive, :month, :year]

  POSTS_ON_FRONT_PAGE = 3

  # GET /
  def home
    # Read the desired number of posts + 1
    @posts = Post.public_posts.for_locale(I18n.locale).order(face_date: :desc).limit(POSTS_ON_FRONT_PAGE + 1).to_a
    if @posts.size > POSTS_ON_FRONT_PAGE
      post_pre_last = @posts[-2].to_month_url
      post_last = @posts.last.to_month_url
      if post_pre_last != post_last
        # If the last post belong to the different month it is not shown
        # but is used to generate the 'Previous month' link
        @prev_month = post_last
        @posts.pop
      else
        # we fetch and show all the rest of posts
        @posts.concat(
          Post.public_posts.month(post_last[:year], post_last[:month])
              .reorder(face_date: :desc).where.not(id: @posts.map(&:id))
        )
        @prev_month = Post.public_posts.prev_month(post_last[:year], post_last[:month])
      end
    end

    # @cell0 = YearSummaryCell.new(year: Quails::CURRENT_YEAR - 1)
    @cell = YearProgressCell.new(year: Quails::CURRENT_YEAR, offset: 8.hours)
  end

  def archive
    @years = current_user.available_posts.for_locale(I18n.locale).years
    archive_sql =
      current_user
        .available_posts
        .for_locale(I18n.locale)
        .select("EXTRACT(year FROM face_date)::integer as raw_year,
                EXTRACT(month FROM face_date)::integer as raw_month,
                COUNT(id) as posts_count")
        .group("raw_year, raw_month")
        .order("raw_year, raw_month")
        .to_sql
    @archive = ActiveRecord::Base.connection.select_all(archive_sql).chunk { |row| row["raw_year"] }
  end

  def month
    @posts = current_user.available_posts.for_locale(I18n.locale).month(@year = params[:year], @month = params[:month])
    @prev_month = current_user.available_posts.for_locale(I18n.locale).prev_month(@year, @month)
    @next_month = current_user.available_posts.for_locale(I18n.locale).next_month(@year, @month)
  end

  def year
    @posts = current_user.available_posts.for_locale(I18n.locale).year(@year = params[:year])
    @months = @posts.chunk(&:month)
    @years = current_user.available_posts.for_locale(I18n.locale).years
  end
end
