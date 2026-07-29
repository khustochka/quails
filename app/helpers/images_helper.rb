# frozen_string_literal: true

module ImagesHelper
  ON_FLICKR_IMG = {
    true => ["https://s.yimg.com/pw/images/goodies/white-small-chiclet.png", "On flickr"],
    false => ["https://s.yimg.com/pw/images/goodies/black-small-chiclet.png", "Not on flickr"],
  }

  def jpg_url(img)
    if img.on_storage?
      img.stored_image.url
    elsif img.on_flickr?
      img.assets_cache.externals.main_image.full_url
    else
      img.assets_cache.locals.main_image.try(:full_url) || legacy_image_url("#{img.slug}.jpg")
    end
  end

  # Dimensions of the asset that jpg_url points to (nil if unknown),
  # for width/height img attributes reserving layout space before load.
  def jpg_dimensions(img)
    if img.on_storage?
      width, height = img.stored_image.metadata.values_at(:width, :height)
      { width: width, height: height } if width && height
    else
      asset = img.assets_cache.public_send(img.on_flickr? ? :externals : :locals).main_image
      { width: asset.width, height: asset.height } if asset && !asset.dummy_dimensions?
    end
  end

  # == Sizing images that sit in a bordered wrapper
  #
  # Applies to figure.imageholder (posts) and .image_canvas (photo and species
  # pages): a shrink-to-fit box drawing a visible border around the image.
  # Three requirements, all of which have to hold at once:
  #
  # 1. Reserve layout space. The box must have its final size before the image
  #    loads, or the page jumps as images arrive.
  # 2. Cap the height to the viewport, so a tall portrait image doesn't force
  #    scrolling, and never distort the aspect ratio or upscale past natural size.
  # 3. Hug the image. The wrapper's border has to sit against the image on all
  #    four sides, at any viewport size, without overflowing narrow screens.
  #
  # The catch is that 1 and 3 pull against each other. Reserving space needs the
  # image's width to be known up front; hugging needs the wrapper to shrink to
  # whatever width the capped image ends up at. And a shrink-to-fit wrapper
  # measures its child's *intrinsic* width — the width attribute — so anything
  # that only narrows the image at paint time leaves the border stretched.
  #
  # Simpler placements of the cap that were measured and rejected:
  #
  #   max-width: min(100%, calc(cap * ratio)) on the img
  #     Ratio and reservation fine, but the percentage inside min() is resolved
  #     against an indefinite width during intrinsic sizing, so the wrapper
  #     measures the full width attribute -> border stretched past the image.
  #   Same, minus the 100% term
  #     Hugs correctly, but nothing clamps to the container -> narrow viewports
  #     scroll horizontally.
  #   max-height on the img, keeping the width attribute
  #     Width stays pinned while height is capped -> image squished.
  #   width/height: auto on the img
  #     Scales and hugs correctly, but auto/auto discards the attribute-derived
  #     box entirely -> no space reserved (CLS 0.13 on a post page).
  #   width: min(...) or aspect-ratio on the img
  #     Same intrinsic-sizing poisoning as the first case.
  #   Wrapper as inline-grid instead of inline-block
  #     Grid tracks still size to the intrinsic width -> border still stretched.
  #
  # What works: move the cap off the image and onto the wrapper (see
  # image_frame_attrs). The wrapper then has a definite width instead of
  # shrink-wrapping, so nothing is measured intrinsically; the image fills it
  # (width: 100% in CSS) and an inline aspect-ratio keeps the box proportional
  # before load. Images with unknown dimensions get no inline width and fall
  # back to the max-height rules in the stylesheets.

  # Fit the viewport height, but don't shrink in short-wide windows
  POST_IMG_HEIGHT_CAP = "max(97vh, 700px)"
  CANVAS_IMG_HEIGHT_CAP = "max(95vh, 700px)"

  # width/height attributes plus an explicit aspect-ratio, so the box keeps its
  # proportions before load. The wrapper (see image_frame_attrs) is what
  # actually reserves the space.
  def dimension_attrs(dims)
    return {} unless dims

    {
      width: dims[:width], height: dims[:height],
      style: "aspect-ratio: #{dims[:width]} / #{dims[:height]}",
    }
  end

  # Inline width for the wrapper: the smallest of the container width, the
  # image's natural width (never upscale) and the height cap converted to a
  # width via the aspect ratio.
  def image_frame_attrs(dims, cap: POST_IMG_HEIGHT_CAP)
    return {} unless dims

    cap_width = "calc(#{cap} * #{dims[:width]} / #{dims[:height]})"
    { style: "width: min(100%, #{dims[:width]}px, #{cap_width})" }
  end

  # Maps each distinct justified box size to the `aspect-ratio` value its rule
  # should use. Sizes with known natural dimensions get the served asset's
  # ratio, so the box matches the image exactly instead of the rounded box
  # dimensions; the rest fall back to the box itself.
  def thumbnail_size_rules(thumbnails)
    thumbnails.each_with_object({}) do |thumb, rules|
      key = [thumb.width, thumb.height]
      next if rules.key?(key)

      natural = thumb.natural_dimensions
      rules[key] = "#{natural ? natural[0] : key[0]} / #{natural ? natural[1] : key[1]}"
    end
  end

  def static_jpg_url(img, options = {})
    image_url(img, options.merge({ format: :jpg }))
  end

  THUMBNAIL_HEIGHT = 280

  # [src, extra img attributes] for an image source that may be a variant.
  # With Quails.direct_variant_urls? and a processed variant it returns the
  # direct storage URL, keeping the redirect route in data-fallback-src so JS
  # can recover if the direct URL goes stale (see image-fallback.js).
  def variant_src_with_fallback(source)
    if Quails.direct_variant_urls? &&
        source.is_a?(ActiveStorage::VariantWithRecord) &&
        (direct_url = source.url)
      [direct_url, { data: { fallback_src: url_for(source) } }]
    else
      [source, {}]
    end
  end

  def thumbnail_item(img)
    if img.on_storage?
      img.stored_image_to_asset_item
    elsif img.on_flickr?
      img.assets_cache.externals.thumbnail
    else
      img.assets_cache.locals.thumbnail
    end
  end

  class << self
    attr_writer :image_host
    attr_writer :local_image_path
    attr_writer :temp_image_path

    def image_host
      @image_host ||= ENV["quails_image_host"]
    end

    private

    def local_image_path
      return @local_image_path if @local_image_path

      @local_image_path = ENV["quails_local_image_path"]
      FileUtils.mkdir_p(@local_image_path) if @local_image_path
      @local_image_path
    end

    def temp_image_path
      return @temp_image_path if @temp_image_path

      @temp_image_path = ENV["quails_temp_image_path"]
      FileUtils.mkdir_p(@temp_image_path) if @temp_image_path
      @temp_image_path
    end
  end

  private

  def legacy_image_url(file_name)
    "#{ImagesHelper.image_host}#{file_name}"
  end

  def flickr_img_format
    @flickr_img_format || :url_m
  end

  def flickr_img_url_function(flickr_image)
    if @flickr_img_url_lambda
      @flickr_img_url_lambda.call(flickr_image)
    else
      FlickRaw.url_photopage(flickr_image)
    end
  end

  def srcset_convert_urls(srcset)
    srcset.map do |url, size|
      [url_for(url), size]
    end
  end
end
