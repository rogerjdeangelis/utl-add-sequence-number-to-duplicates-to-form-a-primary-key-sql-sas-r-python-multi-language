%let pgm=utl-add-sequence-number-to-duplicates-to-form-a-primary-key-sql-sas-r-python-multi-language;

%stop_submission;

Add sequence number to duplicates to form a primary key sql sas r python multi language

SOLUTIONS

   1 sas sql (place is a fact variable and should not be part of the promary key)
   2 r sql
   3 python sql
   4 sqlpartition macro
   5 related sql partitioning

SOAPBOX ON

 SQL PARTITIONING, ADD A SEQUENCE NUMBER, HAS MANY APPLICATIONS.

   1 creating a primary key
   2 transposing pivoting
   3 time series
   4 cumulative sums
   5 first dot last.dot
   6 form groups of different sizes or similar sums
   7 select equal size groups
   8 select top n
   9 lags

SOAPBOX OFF

github
https://tinyurl.com/5n2a28hd
https://github.com/rogerjdeangelis/utl-add-sequence-number-to-duplicates-to-form-a-primary-key-sql-sas-r-python-multi-language

SAS Commumity
related to
https://stackoverflow.com/questions/79287926/uniform-a-variable-value-by-other-variables

macros
https://tinyurl.com/y9nfugth
https://github.com/rogerjdeangelis/utl-macros-used-in-many-of-rogerjdeangelis-repositories

/*               _     _
 _ __  _ __ ___ | |__ | | ___ _ __ ___
| `_ \| `__/ _ \| `_ \| |/ _ \ `_ ` _ \
| |_) | | | (_) | |_) | |  __/ | | | | |
| .__/|_|  \___/|_.__/|_|\___|_| |_| |_|
|_|
*/

/***********************************************************************************************************************************/
/*                                  |                                                      |             OUTPUT                    */
/*           INPUT                  |          PROCESS                                     |             ======                    */
/*           =====                  |          ========                                    |                                       */
/*                             PlA- |                                                      |                           PL-         */
/*   ID     START      END      ACE | SORTED FOR DOCUMENTATION PURPOSES ONLY               |  ID    START       END    ACE PART=   */
/*                                  | DATA DOES NOT HAVE TO BE SORTED                      |                               ITION   */
/*  0002 2015-01-01 2015-12-31  0   |                                                      |                                       */
/*  0001 2015-01-13 2015-01-20  0   | ADD  SEQUENCE NUMBER TO DUP GROUPS                   | 0001 2015-01-13 2015-01-20  1  1      */
/*  0001 2015-01-21 2015-12-31  0   | ID, START and END                                    | 0001 2015-01-13 2015-01-20  1  2      */
/*  0001 2018-01-01 2018-12-31  0   |                                                      | 0001 2015-01-13 2015-01-20  0  3      */
/*  0001 2015-01-13 2015-01-20  1   |                                     ADD THIS         | 0001 2015-01-21 2015-12-31  0  1      */
/*  0001 2019-01-01 2019-12-31  0   |   ID    START       END     PLACE   PARTITION        | 0001 2018-01-01 2018-12-31  0  1      */
/*  0001 2015-01-13 2015-01-20  1   |                                                      | 0001 2019-01-01 2019-12-31  0  1      */
/*  0002 2015-01-01 2015-12-31  0   |  0001 2015-01-13 2015-01-20   0     1 same id,start  | 0002 2015-01-01 2015-12-31  0  1      */
/*                                  |  0001 2015-01-13 2015-01-20   1     2 and, end       | 0002 2015-01-01 2015-12-31  0  2      */
/*                                  |  0001 2015-01-13 2015-01-20   1     3                |                                       */
/*  options validvarname=upcase;    |                                                      |                                       */
/*  libname sd1 "d:/sd1";           |  0001 2015-01-21 2015-12-31   0     1 Singletons     |                                       */
/*  data sd1.have;                  |  0001 2018-01-01 2018-12-31   0     1                |                                       */
/*   informat id $4. start          |  0001 2019-01-01 2019-12-31   0     1                |                                       */
/*            end $10. place $1.;   |                                                      |                                       */
/*   input ID start end place ;     |  0002 2015-01-01 2015-12-31   0     1 same id,start  |                                       */
/*   put id start end place;        |  0002 2015-01-01 2015-12-31   0     2 ,and end       |                                       */
/*  cards4;                         |                                                      |                                       */
/*  0002 2015-01-01 2015-12-31 0    |------------------------------------------------------|                                       */
/*  0001 2015-01-13 2015-01-20 0    |                                                      |                                       */
/*  0001 2015-01-21 2015-12-31 0    | 1 SAS PARTITIONING                                   |                                       */
/*  0001 2018-01-01 2018-12-31 0    | ===================                                  |                                       */
/*  0001 2015-01-13 2015-01-20 1    |                                                      |                                       */
/*  0001 2019-01-01 2019-12-31 0    | select                                               |                                       */
/*  0001 2015-01-13 2015-01-20 1    |    *                                                 |                                       */
/*  0002 2015-01-01 2015-12-31 0    |   ,place                                             |                                       */
/*  ;;;;                            |   ,partition as seq                                  |                                       */
/*  run;quit;                       | from                                                 |                                       */
/*                                  |    %sqlpartition(                                    |                                       */
/*                                  | sd1.have,                                            |                                       */
/*                                  |    by=%str(id, start, end))                          |                                       */
/*                                  |                                                      |                                       */
/*                                  | %macro sqlPartition(data,by=);                       |                                       */
/*                                  |                                                      |                                       */
/*                                  |   (select                                            |                                       */
/*                                  |      row_number                                      |                                       */
/*                                  |     ,row_number-min(row_number)+1 as partition       |                                       */
/*                                  |     ,*                                               |                                       */
/*                                  |   from                                               |                                       */
/*                                  |     (select *, monotonic() as row_number from        |                                       */
/*                                  |      (select *,max(%scan(%str(&by),1,%str(,)))       |                                       */
/*                                  |     as delete from &data group by &by ))             |                                       */
/*                                  |   group                                              |                                       */
/*                                  |       by &by )                                       |                                       */
/*                                  |                                                      |                                       */
/*                                  | %mend sqlPartition;                                  |                                       */
/*                                  |                                                      |                                       */
/*                                  |------------------------------------------------------|                                       */
/*                                  |                                                      |                                       */
/*                                  | 2 R and PYTHON SQL                                   |                                       */
/*                                  | ==================                                   |                                       */
/*                                  |                                                      |                                       */
/*                                  | select                                               |                                       */
/*                                  |   *                                                  |                                       */
/*                                  | from                                                 |                                       */
/*                                  |   (select                                            |                                       */
/*                                  |       *                                              |                                       */
/*                                  |      ,row_number() as partition                      |                                       */
/*                                  |    over                                              |                                       */
/*                                  |      (partition by id,start,end) as partition        |                                       */
/*                                  |    from have                                         |                                       */
/*                                  |   )                                                  |                                       */
/*                                  |                                                      |                                       */
/************************************************************************************************|**********************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
 informat id $4. start end $10. place $1.;
 input ID start end place ;
 put id start end place;
cards4;
0002 2015-01-01 2015-12-31 0
0001 2015-01-13 2015-01-20 0
0001 2015-01-21 2015-12-31 0
0001 2018-01-01 2018-12-31 0
0001 2015-01-13 2015-01-20 1
0001 2019-01-01 2019-12-31 0
0001 2015-01-13 2015-01-20 1
0002 2015-01-01 2015-12-31 0
;;;;
run;quit;

/*                             _
/ |  ___  __ _ ___   ___  __ _| |
| | / __|/ _` / __| / __|/ _` | |
| | \__ \ (_| \__ \ \__ \ (_| | |
|_| |___/\__,_|___/ |___/\__, |_|
                            |_|
*/
proc sql;
create
   table want as
select
   id
  ,start
  ,end
  ,place
  ,partition
from
   %sqlpartition(
sd1.have,
   by=%str(id, start, end))
;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*   ID       START          END        PLACE  PARTITION                                                                  */
/*                                                                                                                        */
/*  0001    2015-01-13    2015-01-20      1       1                                                                       */
/*  0001    2015-01-13    2015-01-20      1       2                                                                       */
/*  0001    2015-01-13    2015-01-20      0       3                                                                       */
/*  0001    2015-01-21    2015-12-31      0       1                                                                       */
/*  0001    2018-01-01    2018-12-31      0       1                                                                       */
/*  0001    2019-01-01    2019-12-31      0       1                                                                       */
/*  0002    2015-01-01    2015-12-31      0       1                                                                       */
/*  0002    2015-01-01    2015-12-31      0       2                                                                       */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*___                     _
|___ \   _ __   ___  __ _| |
  __) | | `__| / __|/ _` | |
 / __/  | |    \__ \ (_| | |
|_____| |_|    |___/\__, |_|
                       |_|
*/


%utl_rbeginx;
parmcards4;
library(haven)
library(sqldf)
source("c:/oto/fn_tosas9x.r")
have<-read_sas("d:/sd1/have.sas7bdat")
print(have)
want <- sqldf('
 select
   *
 from
   (select
       *
      ,row_number() as partition
    over
      (partition by id,start,end) as partition
    from have
   )
 ')
want;
fn_tosas9x(
      inp    = want
     ,outlib ="d:/sd1/"
     ,outdsn ="rwant"
     )
;;;;
%utl_rendx;

proc print data=sd1.rwant;
run;quit;

/**************************************************************************************************************************/
/*                                                  |                                                                     */
/*  R                                               | SAS                                                                 */
/*                                                  |                                                                     */
/*      ID      START        END PLACE PARTITION    |  ROWNAMES     ID       START          END        PLACE    PARTITION */
/*                                                  |                                                                     */
/*  1 0001 2015-01-13 2015-01-20     0         1    |      1       0001    2015-01-13    2015-01-20      0          1     */
/*  2 0001 2015-01-13 2015-01-20     1         2    |      2       0001    2015-01-13    2015-01-20      1          2     */
/*  3 0001 2015-01-13 2015-01-20     1         3    |      3       0001    2015-01-13    2015-01-20      1          3     */
/*  4 0001 2015-01-21 2015-12-31     0         1    |      4       0001    2015-01-21    2015-12-31      0          1     */
/*  5 0001 2018-01-01 2018-12-31     0         1    |      5       0001    2018-01-01    2018-12-31      0          1     */
/*  6 0001 2019-01-01 2019-12-31     0         1    |      6       0001    2019-01-01    2019-12-31      0          1     */
/*  7 0002 2015-01-01 2015-12-31     0         1    |      7       0002    2015-01-01    2015-12-31      0          1     */
/*  8 0002 2015-01-01 2015-12-31     0         2    |      8       0002    2015-01-01    2015-12-31      0          2     */
/*                                                  |                                                                     */
/**************************************************************************************************************************/

/*____               _   _                             _
|___ /   _ __  _   _| |_| |__   ___  _ __    ___  __ _| |
  |_ \  | `_ \| | | | __| `_ \ / _ \| `_ \  / __|/ _` | |
 ___) | | |_) | |_| | |_| | | | (_) | | | | \__ \ (_| | |
|____/  | .__/ \__, |\__|_| |_|\___/|_| |_| |___/\__, |_|
        |_|    |___/                                |_|
*/

proc datasets lib=sd1 nolist nodetails;
 delete pywant;
run;quit;

%utl_pybeginx;
parmcards4;
exec(open('c:/oto/fn_python.py').read());
have,meta = ps.read_sas7bdat('d:/sd1/have.sas7bdat');
want=pdsql('''
 select                                                      \
   *                                                         \
 from                                                        \
   (select                                                   \
       *                                                     \
      ,row_number()                                          \
    over                                                     \
      (partition by id,start,end) as partition               \
    from have                                                \
   )                                                         \
   ''')
print(want);
fn_tosas9x(want,outlib='d:/sd1/',outdsn='pywant',timeest=3);
;;;;
%utl_pyendx;

proc print data=sd1.pywant;
run;quit;

/**************************************************************************************************************************/
/*                                                       |                                                                */
/*  R                                                    |                                                                */
/*                                                       |                                                                */
/*       ID       START         END PLACE  partition     |   ID       START          END        PLACE    PARTITION        */
/*                                                       |                                                                */
/*  0  0001  2015-01-13  2015-01-20     0          1     |  0001    2015-01-13    2015-01-20      0          1            */
/*  1  0001  2015-01-13  2015-01-20     1          2     |  0001    2015-01-13    2015-01-20      1          2            */
/*  2  0001  2015-01-13  2015-01-20     1          3     |  0001    2015-01-13    2015-01-20      1          3            */
/*  3  0001  2015-01-21  2015-12-31     0          1     |  0001    2015-01-21    2015-12-31      0          1            */
/*  4  0001  2018-01-01  2018-12-31     0          1     |  0001    2018-01-01    2018-12-31      0          1            */
/*  5  0001  2019-01-01  2019-12-31     0          1     |  0001    2019-01-01    2019-12-31      0          1            */
/*  6  0002  2015-01-01  2015-12-31     0          1     |  0002    2015-01-01    2015-12-31      0          1            */
/*  7  0002  2015-01-01  2015-12-31     0          2     |  0002    2015-01-01    2015-12-31      0          2            */
/*                                                       |                                                                */
/**************************************************************************************************************************/

/*____             _                    _   _ _   _
|___ /   ___  __ _| |  _ __   __ _ _ __| |_(_) |_(_) ___  _ __    _ __ ___   __ _  ___ _ __ ___
  |_ \  / __|/ _` | | | `_ \ / _` | `__| __| | __| |/ _ \| `_ \  | `_ ` _ \ / _` |/ __| `__/ _ \
 ___) | \__ \ (_| | | | |_) | (_| | |  | |_| | |_| | (_) | | | | | | | | | | (_| | (__| | | (_) |
|____/  |___/\__, |_| | .__/ \__,_|_|   \__|_|\__|_|\___/|_| |_| |_| |_| |_|\__,_|\___|_|  \___/
                |_|   |_|
*/

%macro sqlPartition(data,by=);

  (select
     row_number
    ,row_number - min(row_number) +1 as partition
    ,*
  from
      (select *, monotonic() as row_number from
         (select *, max(%scan(%str(&by),1,%str(,))) as delete from &data group by &by ))
  group
      by &by )

%mend sqlPartition;

/*___
| ___|   _ __ ___ _ __   ___  ___
|___ \  | `__/ _ \ `_ \ / _ \/ __|
 ___) | | | |  __/ |_) | (_) \__ \
|____/  |_|  \___| .__/ \___/|___/
                 |_|
*/

 REPO
 ----------------------------------------------------------------------------------------------------------------------------------------
 https://github.com/rogerjdeangelis/utl-adding-sequence-numbers-and-partitions-in-SAS-sql-without-using-monotonic
 https://github.com/rogerjdeangelis/utl-create-equally-spaced-values-using-partitioning-in-sql-wps-r-python
 https://github.com/rogerjdeangelis/utl-create-primary-key-for-duplicated-records-using-sql-partitionaling-and-pivot-wide-sas-python-r
 https://github.com/rogerjdeangelis/utl-find-first-n-observations-per-category-using-proc-sql-partitioning
 https://github.com/rogerjdeangelis/utl-flag-second-duplicate-using-base-sas-and-sql-sas-python-and-r-partitioning-multi-language
 https://github.com/rogerjdeangelis/utl-incrementing-by-one-for-each-new-group-of-records-sas-r-python-sql-partitioning
 https://github.com/rogerjdeangelis/utl-macro-to-enable-sql-partitioning-by-groups-montonic-first-and-last-dot
 https://github.com/rogerjdeangelis/utl-partitioning-your-table-for-a-big-parallel-systask-sort
 https://github.com/rogerjdeangelis/utl-pivot-long-pivot-wide-transpose-partitioning-sql-arrays-wps-r-python
 https://github.com/rogerjdeangelis/utl-pivot-transpose-by-id-using-wps-r-python-sql-using-partitioning
 https://github.com/rogerjdeangelis/utl-sql-partitioning-increase-in-investment-when-interest-rates-change-over-time-compound-interest
 https://github.com/rogerjdeangelis/utl-top-four-seasonal-precipitation-totals--european-cities-sql-partitions-in-wps-r-python
 https://github.com/rogerjdeangelis/utl-transpose-pivot-wide-using-sql-partitioning-in-wps-r-python
 https://github.com/rogerjdeangelis/utl-transposing-rows-to-columns-using-proc-sql-partitioning
 https://github.com/rogerjdeangelis/utl-transposing-words-into-sentences-using-sql-partitioning-in-r-and-python
 https://github.com/rogerjdeangelis/utl-using-DOW-loops-to-identify-different-groups-and-partition-data
 https://github.com/rogerjdeangelis/utl-using-sql-in-wps-r-python-select-the-four-youngest-male-and-female-students-partitioning
 https://github.com/rogerjdeangelis/utl_partition_a_list_of_numbers_into_3_groups_that_have_the_similar_sums_python
 https://github.com/rogerjdeangelis/utl_partition_a_list_of_numbers_into_k_groups_that_have_the_similar_sums
 https://github.com/rogerjdeangelis/utl_scalable_partitioned_data_to_find_statistics_on_a_column_by_a_grouping_variable


/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
