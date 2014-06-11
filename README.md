Kaggle Acquired Value Shoppers Challenge
----------------------------------------

See https://www.kaggle.com/c/acquire-valued-shoppers-challenge

Set up
------

1. Create folders:

* `data/` for original data file
* `interm/` for intermediate files
* `target/` for prediction results

2. Download all data files into the directory `data`

3. Go into a directory starting with `algo` and run `make all`

4. This will generate prediction results in the `target` directory and output
   the area under the ROC curve

Development
-----------

To develop more models, create more directories that starts with the word `algo`
