class GuidesController < ApplicationController
  PAGES = [
    {
      title: 'Into',
      pages: [
        { title: "What & Why", path: "" }
      ],
    },
    {
      title: 'Getting Started',
      pages: [
        { title: "Tools", path: "/getting-started/tools" },
        { title: "Using the CLI", path: "/getting-started/using-the-cli" },
        { title: "Configuration", path: "/getting-started/configuration" },
        { title: "The Main Component", path: "/getting-started/the-main-component" },
        { title: "Styling with CSS", path: "/getting-started/styling-with-css" },
        { title: "Handling Events", path: "/getting-started/handling-events" },
      ]
    },
    {
      title: 'Recipies',
      pages: [
        { title: "Using third party CSS", path: "/recipies/using-third-party-css" }
      ]
    },
      title: 'Reference',
      pages: [
        { title: "Literals", path: "/reference/literals" },
        { title: "Arrays", path: "/reference/arrays" },
        { title: "Tuples", path: "/reference/tuples" },
        { title: "Functions", path: "/reference/functions" },
        { title: "Records", path: "/reference/records" },
        { title: "Enums", path: "/reference/enums" },
        { title: "Built in Types", path: "/reference/built-in-types" },
        { title: "Equality", path: "/reference/equality" },
        { title: "Stores", path: "/reference/stores" },
        { title: "Routing", path: "/reference/routing" },
        {
          title: "Control Expressions",
          path: "/reference/control-expressions",
          pages: [
            { title: "if...else", path: "/reference/control-expressions/if-else" },
            { title: "case", path: "/reference/control-expressions/case" },
            { title: "for", path: "/reference/control-expressions/for" },
            { title: "try", path: "/reference/control-expressions/try" },
            { title: "sequence", path: "/reference/control-expressions/sequence" },
            { title: "parallel", path: "/reference/control-expressions/parallel" },
          ]
        },
        {
          title: "Components",
          path: "/reference/components",
          pages: [
            { title: "Properties", path: "/reference/components/properties" },
            { title: "Computed Properties", path: "/reference/components/computed-properties" },
            { title: "Styling Elements", path: "/reference/components/styling-elements" },
            { title: "Connecting Stores", path: "/reference/components/connecting-stores" },
            { title: "Using Providers", path: "/reference/components/using-providers" },
            { title: "Internal State", path: "/reference/components/internal-state" },
            { title: "Referencing Entities", path: "/reference/components/referencing-entities" },
            { title: "Global Components", path: "/reference/components/global-components" },
          ]
        },
        {
          title: "JavaScript Interop",
          path: "/reference/javascript-interop",
          pages: [
            { title: "Inlining", path: "/reference/javascript-interop/inlining" },
            { title: "Decode Expression", path: "/reference/javascript-interop/decode-expression" },
            { title: "Encode Expression", path: "/reference/javascript-interop/encode-expression" },
          ]
        },
        { title: "Environment Variables", path: "/reference/environment-variables", pages: [] },
        { title: "Packages", path: "/reference/packages" },
      ]
  ]

  FLATTENED_PAGES =
    PAGES.reduce([]) do |memo, page|
      page[:pages].to_a.each do |subpage|
        memo << subpage

        subpage[:pages].to_a.each do |item|
          memo << item
        end
      end

      memo
    end

  def page
    path =
      File.join(Rails.root, 'app', 'views', 'guides', 'pages', params[:page] + ".haml")

    index =
      FLATTENED_PAGES.find_index { |item| item[:path] == "/" + params[:page] }

    if index
      @next = FLATTENED_PAGES[index + 1]
      @previous = FLATTENED_PAGES[index - 1]
    end

    if File.exist?(path)
      @page = 'guides/pages/' + params[:page]
    else
      index =
        File.join(Rails.root, 'app', 'views', 'guides', 'pages', params[:page], "index.haml")

      if File.exist?(index)
        @page = 'guides/pages/' + params[:page] + '/index'
      else
        redirect_to '/guide'
      end
    end

  end

  def index
    set_meta_tags title: 'Guide'
  end
end
