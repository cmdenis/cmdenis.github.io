# Instructions: simply write the markdown file to be generated in the same folder as this script. Name the file with the date yyyymmdd.md



# This script will convert all of the markdown files in the directory to html files based on the 
# template html file in the same directory. It will scan for the keywords
# 1. zzzblogtitleherezzz: will replace it with the appropriate title in the mardown file.
# 2. zzzmaintextherezzz: will replace it with the appropriate html code from the markdown file. 
#
# It will also edit the blog.html file to show all of the available articles by year


cd("/Users/christiandenis/Website/cmdenis.github.io/blog") # Makes sure we're in the correct directory

# Opening html template file
htmlfile = open("blog_template.html") do file
    read(file, String)
end


for filename in readdir() # Iterates over the files in the directory

    #println("\nThe file name is: ", filename)

    if reverse(filename)[1:3] == "dm." # Checking that file is markdown

        # Opening the file
        mdfile = open(filename) do file
            read(file, String)
        end

        # First we replace the $$ signs so that the $ signs don't get detected
        mdfile = replace(mdfile, "\$\$"=> "******")

        # We should check to see if there are some SAME LINE formulas, so that we format them right from the start.
        # Finds the indices at which there are "$". Since the $$ where already replaced before, there is no chance that
        # this loop will do a mistake between $$ and $.
        s_form_indices = [index[1] for index in findall("\$", mdfile)]
        # Pairs them to have the end and start of each section
        s_paired_indices = [[s_form_indices[i], s_form_indices[i+1]] for i in 1:2:length(s_form_indices)]
        # Stores the text strings into a list
        s_formulas = [mdfile[i[1]:i[2]] for i in s_paired_indices]
        for formula in s_formulas
            replacement = "\\( "*chop(formula, head = 2, tail = 1)*" \\)"
            mdfile = replace(mdfile, formula => replacement)
        end
        # Now we replace the ****** by the appro sign again
        mdfile = replace(mdfile, "******" => "\$\$")
        



        # We get the title
        blogtitle = mdfile[3:findfirst("\n", mdfile)[1]]





        # Then we get the sections

        # Finds the indices at which there is a line break
        section_indices = [index[1] for index in findall("\n", mdfile)]
        # Pairs them to have the end and start of each section
        paired_section_indices = [[section_indices[i], section_indices[i+1]] for i in 2:2:length(section_indices)]
        # Stores the text strings into a list
        sections = [mdfile[i[1]+1:i[2]] for i in paired_section_indices]


        # Now we assemble the text.

        main_content = ""

        for section in sections
            if section[1:3] == "## "
                main_content = main_content*" <h2>"*chop(section, head = 3)*"</h2> "

            elseif section[1:4] == "### "
                main_content = main_content*" <h3>"*chop(section, head = 4)*"</h3> "

            elseif section[1:5] == "#### "
                main_content = main_content*" <h4>"*chop(section, head = 5)*"</h4> "
            else
                main_content = main_content*" <p>"*section*"</p> "
            end
        end



        # Replacing the main content and title of the html file and writing a new html file for it.
        
        # Replace title
        newhtmlfile = replace(htmlfile, "zzzblogtitleherezzz" => blogtitle)
        # Replace content
        newhtmlfile = replace(newhtmlfile, "<p>zzzmaintextherezzz</p>" => main_content)

        # Writing html file with same name as md file
        local htmlfilewrite = open(chop(filename, tail = 3)*".html", "w")
        println(htmlfilewrite, newhtmlfile)
        close(htmlfilewrite)

    end

end

# Now the second part used to modify the blog.html file

blogindex = []

years = []

for filename in reverse(readdir())
    
    if reverse(filename)[1:3] == "dm." # Checking that file is markdown
        
        # Check for year of posts
        year_of_post = filename[1:4]
        if !(year_of_post in years) 
            push!(years, year_of_post)
            push!(blogindex, " <h2>"*string(year_of_post) * "</h2> ")
        end
        
        # Opening the markdown file to get title
        mdfile = open(filename) do file
            read(file, String)
        end

        blogtitle = mdfile[3:findfirst("\n", mdfile)[1]]

        push!(blogindex, """ <h3><a href="blog/"""*filename[1:8]*""".html">"""*blogtitle*"</a></h3> "*"<p class = nospacepar>"*filename[1:4]*"/"*filename[5:6]*"/"*filename[7:8]*"</p> <br>")

    end
end

blogindex = join(blogindex)

cd("/Users/christiandenis/Website/cmdenis.github.io") # Makes sure we're in the correct directory

# Opening html template file
bloghtml = open("blog.html") do file
    read(file, String)
end


firstpart = bloghtml[1:(last(findlast("<p> Welcome to my blog! Feel free to browse around the following posts.</p>", bloghtml))+1)]
lastpart = bloghtml[(findfirst("<footer>", bloghtml)[1]-1):length(bloghtml)]

bloghtml = firstpart * blogindex * lastpart



# Writing html file with same name as md file
htmlfilewrite = open("blog.html", "w")
println(htmlfilewrite, bloghtml)
close(htmlfilewrite)




