---
title: Automating Your Resume with Github
date: 2021-04-24 01:20:00 -0600
categories: [Tutorials]
tags: [github, websites, automation, actions, latex, jekyll, resume]     # TAG names should always be lowercase
pin: no
---

## Background

Making your resume easily available and up to date can be quite the task. The approach I have taken is to host my resume on Github.
Github has tools that make it easy to have links that always point to the latest version of a file, which is what we need for my approach.

What this approach uses:

- A repository for hosting the resume LaTeX **code**.
- Github actions for building the resume.
- Git tags to tell Github when to build and "release" the resume PDF.

The final result of this process is something that, when set up, can be operated completely from the Git command line. All you have to do is commit changes to your
resume repository, then create a tag when the resume is in a presentable state. A link can be put on your website that always points to the latest PDF.

## Writing Your Resume

This guide assumes your resume is written in LaTeX. If yours is not, it is pretty easy to learn. I do not have any specific guides to share, I just googled every
question I needed answered to learn. You can check out [my resume repository](https://github.com/Lyndeno/resume) if you need ideas. You will want to put the source
onto a Github repository so that you can set up the automated generation.

## Github Workflow

Configuring the Github workflow to run is pretty simple. We can start with the starter
template that Github provides and build onto it.

Along with the workflow we are building, there are a couple of external actions we can
utilize:

- [xu-cheng/latex-action](https://github.com/xu-cheng/latex-action) for building our LaTeX documents.
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release) for adding the built PDF to the Github release.

### Configuring Run Conditions

We need to configure what triggers our workflow to run. We want to run the action whenever we
push a new tag to the repository. This part of the yml file will configure the workflow to run under these conditions:

``` yml
name: BuildPDF

on:
  push:
    tags:
      - '*' # this formatting can be changed
```

The tags formatting can be changed if you want only major or minor version changes to trigger the workflow.

### Workflow Job

We have to run a number of steps to buid our PDF:

1. Checkout our repository into the workflow workspace.
2. Use [latex-action](https://github.com/xu-cheng/latex-action) to build the pdf.
3. Use [action-gh-release](https://github.com/softprops/action-gh-release) to attach the PDF to the latest release as a source file.

We can accomplish this with this:

``` yml
jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Github Action for LaTeX
        uses: xu-cheng/latex-action@v2
        with:
          root_file: |
            myresume.tex
      - name: Release
        uses: softprops/action-gh-release@v1
        with:
          files: myresume.pdf # Same base name as the .tex file
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

This code tells the system to run on the latest version of Ubuntu. The workflow then checks out the repository to the working directory. We then call the latex action to build the PDF, giving it the name of our source LaTeX file. The next step, titled "Release", pushes the specified PDF to the releases page. The PDF will be in the same folder as the LaTeX file and have the same name. The ```GITHUB_TOKEN``` line is for allowing the workflow to authenticate with Github so that it can create a release.

The workflow file is simple to create and is placed under ```.github/workflows/myworkflow.yml```. An example of mine can be seen [here](https://github.com/Lyndeno/resume/blob/master/.github/workflows/buildpdf.yml). Pushing this file to the repository will enable the workflow.

## Using the Workflow

### Triggering the Workflow with Tags

If you do not know how to use tags in Git, it is pretty simple.

You will make changes to your resume as usual, then commit and push them to Github. Github will not build the resume if configured as shown previously, you will need to tag. A tag is pretty much a reference point to a certain commit in the history of the code. If I want to create the ```1.0``` tag I can run the following in my repository:

``` sh
$ git tag 1.0 -m "First tag"
```

This will create a new tag called ```1.0``` in the repository. A normal Git push will not send the new tag to Github. We will use a flag when pushing:

``` sh
$ git push --tags
```

Github will now receive the new tag and trigger the workflow. You can check the status of the workflow under the Actions tab on your repository. It will show a yellow dot when the workflow is not finished. A green check mark will show once the workflow has finished and you should now see a new release under the Releases section of your repository. Under that new release should be your resume PDF, great!

### Linking to Your Resume

Github makes it simple to link to the latest release. You can append ```/releases/latest/download/``` to the end of your repository URL to specify a file download for the latest release. In my case it is: [https://github.com/Lyndeno/resume/releases/latest/download/lsanche.pdf](https://github.com/Lyndeno/resume/releases/latest/download/lsanche.pdf). You can put this link onto your website or share it somewhere else. Whenever that link is clicked, your latest resume PDF will be downloaded, and that is it!
