
## Task
```
tasks:                                                                                                                                                             
  - name: What day of the week is Monday the first of October 2019?                                                                                                                                               
    set_fact:                                                                                                                                                      
      my_date: '{{ ("2019-10-01" | to_datetime("%Y-%m-%d")).strftime("%A") }}'   
```

## Contents of `my_date`
```
Monday
```

This uses the `to_datetime` filter in ansible then calls the strftime method on the date/time object.

Refer to the strftime docs linked below for all sorts of other things you can do with date objects.
http://strftime.org/

