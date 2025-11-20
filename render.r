# build.R

# Run Quarto rendering for English and German profiles, then preview
system("quarto render --profile english")
system("quarto render --profile german")
system("quarto preview")