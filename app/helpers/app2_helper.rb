# frozen_string_literal: true

module App2Helper
  def simple_page_header(title)
    tag.header(class: %w[
      text-center md:text-left
      my-5 md:my-10
      pb-4 md:pb-0
      border-b border-[#dddddd] md:border-b-0
    ]) do
      tag.h1(title, class: %w[font-rubik max-md:text-[calc(1.325rem+5vw)]])
    end
  end

  ADMIN_LINK_CLASSES = %w[text-neutral-300 border-b-0 hover:border-b-0 hover:text-white hover:underline].freeze

  def admin_menu_item(label, path, adder: false)
    li_classes = adder ? "inline-block mr-2 text-sm uppercase" : "inline-block mr-2"
    tag.li(class: li_classes) do
      link_to(label, path, class: ADMIN_LINK_CLASSES)
    end
  end

  def admin_menu_logout(path)
    tag.li(class: "inline-block mr-2") do
      link_to("Logout", path, class: %w[
        inline-block px-2 text-sm font-admin font-normal
        bg-[#f8f9fa] text-[#212529] border border-[#dee2e6] cursor-pointer
        hover:bg-[#e9ecef] hover:border-[#dee2e6]
      ])
    end
  end
end
