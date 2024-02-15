#!/usr/bin/env python3




class Transaction:

    def __init__(self, amount, date, currency = "USD", usd_conversion_rate = 1 ,description=None):
        """
        >>> x = Transaction(100, "11 july", "JPY", 0.5, "japanese yen")
        >>> x.amount, x.currency, x.usd_conversion_rate, x.usd
        (100, 'JPY', 0.5, 50.0)
        """
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

