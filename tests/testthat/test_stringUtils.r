context("Unit testing functions in the stringUtils.R file.")

#
# regexprNamedMatches
#
describe( 'regexprNamedMatches()', {
   it( "Retrieves multi-group matched text across a vector of strings", {
      regExp <- "(?<key>.+?)\\s*=\\s*(?<value>.+)"
      data <- c('name = Stuart R. Jefferys', 'email=srj@unc.edu')

      matchResults <- regexpr(regExp, data, perl= TRUE)
      got<-regexprNamedMatches(matchResults, data)
      want<-do.call(cbind, list(key=c('name', 'email'), value=c('Stuart R. Jefferys', 'srj@unc.edu')))
      expect_equal(got, want)
   })

   it( "Retrieves mutli-group matched text from a single string", {
      regExp <- "(?<key>.+?)\\s*=\\s*(?<value>.+)"
      data <- c('name = Stuart R. Jefferys')

      matchResults <- regexpr(regExp, data, perl= TRUE)
      got<-regexprNamedMatches(matchResults, data)
      want<-do.call(cbind, list(key=c('name'), value=c('Stuart R. Jefferys')))
      expect_equal(got, want)
   })

   it( "Retrieves single-group matched text across a vector of strings", {
      regExp <- ".*?(?<num>\\d+).*"
      data <- c('Embedded 123 number', '0234')

      matchResults <- regexpr(regExp, data, perl= TRUE)
      got<-regexprNamedMatches(matchResults, data)
      want<-do.call(cbind, list(num=c('123', '0234')))
      expect_equal(got,want)
   })

   it( "Retrieves empty text string by default when doesn't match", {
      regExp <- "(?<key>.+?)\\s*=\\s*(?<value>\\d+)"
      data <- c('id = 0123', 'email=srj@unc.edu')

      matchResults <- regexpr(regExp, data, perl= TRUE)
      got<-regexprNamedMatches(matchResults, data)
      want<-do.call(cbind, list(key=c('id', ''), value=c('0123', '')))
      expect_equal(got, want)
   })

   it( "Retrieves NA if matches nothing and use.na is specified", {
      regExp <- "(?<key>.+?)\\s*=\\s*(?<value>\\d+)"
      data <- c('id = 0123', 'email=srj@unc.edu')

      matchResults <- regexpr(regExp, data, perl= TRUE)
      got<-regexprNamedMatches(matchResults, data, use.na=TRUE)
      want<-do.call(cbind, list(key=c('id', NA), value=c('0123', NA)))
      expect_equal(got, want)
   })

   it( "Retrieves empty text string by default if matches but captures no text", {
      regExp <- "(?<key>.+?)\\s*=\\s*(?<value>\\d*)"
      data <- c('id = 0123', 'email=srj@unc.edu')

      matchResults <- regexpr(regExp, data, perl= TRUE)
      got<-regexprNamedMatches(matchResults, data)
      want<-do.call(cbind, list(key=c('id', 'email'), value=c('0123', '')))
      expect_equal(got, want)
   })
   it( "Still retrieves empty text string if matches but captures no text when use.na is specified", {
      regExp <- "(?<key>.+?)\\s*=\\s*(?<value>\\d*)"
      data <- c('id = 0123', 'email=srj@unc.edu')

      # Still want '', not NAs
      matchResults <- regexpr(regExp, data, perl= TRUE)
      got<-regexprNamedMatches(matchResults, data, use.na=TRUE)
      want<-do.call(cbind, list(key=c('id', 'email'), value=c('0123', '')))
      expect_equal(got, want)
   })
})

describe( "templateFill() when as.R is FALSE", {
   it("Fills single variable mustache templates with caller variables", {
      templateText <- c(
         "At the end comes {{var1}}.",
         "{{var2}} comes at the start",
         "Also, {{var2}} comes in the middle."
      )
      var1 <- "END"
      var2 <- "A WORD"
      got<-templateFill(templateText);
      want <- c(
         "At the end comes END.",
         "A WORD comes at the start",
         "Also, A WORD comes in the middle."
      )
      expect_equal(got, want)
   })
   it("Fills multi variable mustache templates with caller variables", {
      templateText <- c(
         "{{var1}} and ({{var2}} or {{var3}})",
         "{{var1}}{{var2}}{{var3}}"
      )
      var1 <- "one"
      var2 <- "two"
      var3 <- "three"
      got<-templateFill(templateText);
      want <- c(
         "one and (two or three)",
         "onetwothree"
      )
      expect_equal(got, want)
   })
   it("Fills a template only string with a caller variable", {
      templateText <- "{{var1}}"
      var1 <- "one"
      got<-templateFill(templateText);
      want <- "one"
      expect_equal(got, want)
   })
   it("Leaves non-template containing strings alone", {
      templateText <- c( "{{ Start only.", "End only. }}", "{{", "}}" )
      got<-templateFill(templateText);
      want <- templateText
      expect_equal(got, want)
   })
   it("Leaves empty strings alone", {
      templateText <- c( "", "Nothing", "" )
      got<-templateFill(templateText);
      want <- templateText
      expect_equal(got, want)
   })
   it("Leaves original template strings alone", {
      originalTemplateText <- "{{var1}}"
      var1 <- "one"
      templateFill(originalTemplateText);
      want <- "{{var1}}"
      expect_equal(originalTemplateText, want)

      originalTemplateText <- c(
         "At the end comes {{var1}}.",
         "{{var2}} comes at the start",
         "Also, {{var2}} comes in the middle."
      )
      var1 <- "one"
      var2 <- "two"
      templateFill(originalTemplateText);
      want <- c(
         "At the end comes {{var1}}.",
         "{{var2}} comes at the start",
         "Also, {{var2}} comes in the middle."
      )
      expect_equal(originalTemplateText, want)
   })
   it("Works with non-default template delimiters", {
      templateText <- c(
         "At the end comes <[var1|.",
         "<[var2| comes at the start",
         "Also, <[var2| comes in the middle."
      )
      var1 <- "END"
      var2 <- "A WORD"
      got <- templateFill(templateText, delim = c( "<[", "|" ) );
      want <- c(
         "At the end comes END.",
         "A WORD comes at the start",
         "Also, A WORD comes in the middle."
      )
      expect_equal(got, want)
   })
   it("Works when variables are supplied via the env", {
      templateText <- c(
         "{{var1}} and ({{var2}} or {{var3}})",
         "{{var1}}{{var2}}{{var3}}"
      )
      var1 <- "one"
      var2 <- "two"
      var3 <- "three"
      env=new.env(parent=environment())
      env$var1 = 'A'
      env$var2 = 'B'
      env$var3 = 'C'
      got<-templateFill(templateText, envir=env);
      want <- c(
         "A and (B or C)",
         "ABC"
      )
      expect_equal(got, want)
   })
})

describe( "templateFill() when as.R is TRUE", {
   it("Runs single code mustache templates in (same) caller frame", {
   })
   it("Runs multi variable mustache templates in (same) caller frame", {
   })
   it("Leaves non-template containing strings alone if as.R set", {
   })
   it("Leaves empty strings alone if as.R set", {
   })
   it("Runs code with non-default template delimiters", {
   })
   it("Runs code in the supplied env if its specified", {
   })
   it("Runs code in a shared env across all strings", {
   })
})

describe( "templateFill() exception handling, with and without as.R", {
   it("Dies if mismatched number of open and close delimiters", {
   })
   it("Dies if nested open and close delimiters", {
   })
   it("Dies if out-of order open and close delimiters (close before open)", {
   })
   it("Dies if open and close delimiters are same", {
   })
   it("Dies if R variable not found (as.R = FALSE)", {
   })
   it("Dies if R code fails (as.R = FALSE)", {
   })

})
