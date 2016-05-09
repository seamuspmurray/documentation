#!/usr/bin/env python3



import os
import pickle
import string

class Transaction:

    def __init__(self, amount, date, currency = "USD", usd_conversion_rate = 1 ,description=None):
        """
        >>> x = Transaction(100, "11 july", "JPY", 0.5, "japanese yen")
        >>> x.amount, x.currency, x.usd_conversion_rate, x.usd
        (100, 'JPY', 0.5, 50.0)
        """
        assert type(currency) == str, "currency must be 3 alpha chars eg USD YPY AUD"
        assert len(currency) == 3, "currency must be 3 alhpa chars eg USD YPY AUD"
        self.__amount = amount
        self.__date = date
        self.__currency = currency
        self.__usd_conversion_rate = usd_conversion_rate
        self.__description = description

    @property
    def amount(self):
        return self.__amount 

    @property
    def date(self):
        return self.__date 

    @property
    def currency(self):
        return self.__currency

    @property
    def usd_conversion_rate(self):
        return self.__usd_conversion_rate

    @property
    def description(self):
        return self.__description

    @property
    def usd(self):
        return self.__amount * self.__usd_conversion_rate




if __name__ == "__main__":
    import doctest
    doctest.testmod()


class Account:

    def __init__(self, acc_num, acc_name):
        assert len(acc_name) >= 4, "acc_name must be longer than 4 characters"
        self.__acc_num = acc_num
        self.__acc_name = acc_name
        self.__Transactions = []


    def acc_name(self, acc_name=None):
        if acc_name == None:
            return self.__acc_name
        else:  
            assert len(acc_name) >= 4, "acc_name must be longer than 4 characters"
            self.__acc_name = acc_name

    def apply(self,Transaction):
        self.__Transactions.append(Transaction)
 
    def save(self):
        fh = None
        try:
            #data = [self.__acc_num, self.__acc_name, self.__Transactions]
            data = [self.__acc_num, self.__acc_name, self.__Transactions]
            fh = open(str(self.__acc_num) + ".acc", "wb")
            pickle.dump(data, fh, pickle.HIGHEST_PROTOCOL)
        except (EnvironmentError, pickle.PicklingError) as err:
            raise SaveError(str(err))
        finally:
            if fh is not None:
                fh.close()

        
    def load(self):
        fh = None
        try:
            fh = open(str(self.__acc_num) + ".acc", "rb")
            data = pickle.load(fh)
            self.__acc_num = data[0]
            self.__acc_name = data[1]
            self.__Transactions = data[2]
        except (EnvironmentError, pickle.UnpicklingError) as err:
            raise LoadError(str(err))
        finally:
            if fh is not None:
                fh.close()

    def __len__(self):
        return len(self.__Transactions)

    @property
    def acc_num(self):
        return self.__acc_num
 
    @property
    def balance(self):
        usd_balance = 0.0
        for Transaction in self.__Transactions:
        #   print(Transaction.usd)
            usd_balance += float(Transaction.usd) 
        #   print(usd_balance)
        return usd_balance

    @property
    def all_usd(self):
        is_all_usd = True
        for x in self.__Transactions:
            if x.currency.upper() != "USD":
                print(x.date, x.amount, x.currency, x.usd, x.description)
                is_all_usd = False
        return is_all_usd #if all Transactions are in USD 

    @property
    def statement(self):
        print("date, amount, currency, usd, description")
        for x in self.__Transactions:
            print(x.date, x.amount, x.currency, x.usd, x.description)
