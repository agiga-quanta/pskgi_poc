__author__ = "Nghia Doan"
__copyright__ = "Copyright 2018"
__version__ = "1.0.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Production"


from ast import literal_eval
from configparser import ConfigParser, ExtendedInterpolation


class ConfigHandler(object):
    """
    Configuration file can be created in standard .ini format.
    Section: configuration options are grouped with in sections.
    - Each section has a header where it begins
    - The section scope is valid until the next section header or EOF
    - Each config option consists of one or multiple lines

    [this_is_the_section_header]
    this_is_the_option_name=this_is_the_string_value

    By default all option values are string but can be in other format
    as well. All values must be described in string format
    and can be converted by using get_eval_option()

    Examples:
    number_of_files=1
    file_name=/data/id_list.txt
    list_of_years=1977,1978,1979
    list_of_names_separated_by_commas=Alpha,Beta,Gamma
    dictionary_of_departments={
      'business': ['Mr. X', 'Ms. Y'],
      'finance': ['Mrs. Z'],
      }

    The technique used to support static configuration file
    is from so-called Abstract Syntax Tree (AST), which is a standard
    Python module (https://docs.python.org/3.5/library/ast.html).

    ConfigHandler.get_eval_option(self, section_name, option_name)
    uses ast.literal_eval() to parse and convert textual values
    into standard Python [nested] object instances.

    Note 1: dynamic configuration can also used by changing file content
    and applying reload() function.
    Note 2: Green Tree Snakes is a very detailed documentation for AST
    (https://greentreesnakes.readthedocs.io/en/latest/)
    """

    def __init__(self, config_filename):
        if config_filename is None:
            raise ValueError('Invalid config %s' % config_filename)

        self.config_filename = config_filename
        self.parser = self.__load()

    def __load(self):
        parser = ConfigParser(interpolation=ExtendedInterpolation())

        try:
            parser.read(self.config_filename, encoding='utf-8')
            return parser

        except Exception as ex:
            raise ValueError('Cannot read config %s, %s' % (
                self.config_filename, ex.__traceback__
            ))

    def get_section(self, section_name):
        if section_name is None or section_name not in self.parser:
            return None

        return self.parser[section_name]

    def get_config_option(self, section_name, option_name):
        section = self.get_section(section_name)

        if section is None:
            return None

        if option_name is None or option_name not in section:
            return None

        return section[option_name]

    def get_eval_option(self, section_name, option_name):
        option = self.get_config_option(section_name, option_name)

        if option is None:
            return None

        return literal_eval(option)

    def reload(self):
        self.parser = self.__load()
