Kaggle Acquired Value Shoppers Challenge
----------------------------------------

See https://www.kaggle.com/c/acquire-valued-shoppers-challenge

Set up
------

1. Create folders:
    * `data/` for original data file
    * `interm/` for intermediate files
    * `target/` for prediction results

2. Download all data files into the directory `data` and gunzip them

3. Type `make all` in the root directory to generate all the files derived from
   the data files that the algorithms will need

4. Go to the feature directories (they start with `feature`) and run `make all`
   to generate the necessary features used for the algorithms of choice.

5. Go into a directory starting with `algo` depending on the algorithm of choice
   and run `make all` to test. Run `make submission` to generate the submission file

6. This will generate prediction results in the `target` directory and output
   the area under the ROC curve

6. Go into a directory starting with `algo` and run `make submission` to build the
   submission file

Development
-----------

To develop more models, create more directories that starts with the word `algo`
