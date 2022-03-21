/* A Bison parser, made by GNU Bison 3.7.5.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    IDENTIFIER = 258,              /* IDENTIFIER  */
    CONSTANT = 259,                /* CONSTANT  */
    SIZEOF = 260,                  /* SIZEOF  */
    PTR_OP = 261,                  /* PTR_OP  */
    LE_OP = 262,                   /* LE_OP  */
    GE_OP = 263,                   /* GE_OP  */
    EQ_OP = 264,                   /* EQ_OP  */
    NE_OP = 265,                   /* NE_OP  */
    LT_OP = 266,                   /* LT_OP  */
    GT_OP = 267,                   /* GT_OP  */
    AND_OP = 268,                  /* AND_OP  */
    OR_OP = 269,                   /* OR_OP  */
    AUTO = 270,                    /* AUTO  */
    SWITCH = 271,                  /* SWITCH  */
    CASE = 272,                    /* CASE  */
    UNION = 273,                   /* UNION  */
    EXTERN = 274,                  /* EXTERN  */
    REGISTER = 275,                /* REGISTER  */
    STATIC = 276,                  /* STATIC  */
    TYPEDEF = 277,                 /* TYPEDEF  */
    VOLATILE = 278,                /* VOLATILE  */
    INT = 279,                     /* INT  */
    VOID = 280,                    /* VOID  */
    DOUBLE = 281,                  /* DOUBLE  */
    CHAR = 282,                    /* CHAR  */
    FLOAT = 283,                   /* FLOAT  */
    LONG = 284,                    /* LONG  */
    SHORT = 285,                   /* SHORT  */
    SIGNED = 286,                  /* SIGNED  */
    UNSIGNED = 287,                /* UNSIGNED  */
    STRUCT = 288,                  /* STRUCT  */
    DEFAULT = 289,                 /* DEFAULT  */
    ENUM = 290,                    /* ENUM  */
    IF = 291,                      /* IF  */
    ELSE = 292,                    /* ELSE  */
    WHILE = 293,                   /* WHILE  */
    FOR = 294,                     /* FOR  */
    RETURN = 295,                  /* RETURN  */
    BREAK = 296,                   /* BREAK  */
    CONTINUE = 297,                /* CONTINUE  */
    DO = 298,                      /* DO  */
    GOTO = 299,                    /* GOTO  */
    IFX = 300                      /* IFX  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif
/* Token kinds.  */
#define YYEMPTY -2
#define YYEOF 0
#define YYerror 256
#define YYUNDEF 257
#define IDENTIFIER 258
#define CONSTANT 259
#define SIZEOF 260
#define PTR_OP 261
#define LE_OP 262
#define GE_OP 263
#define EQ_OP 264
#define NE_OP 265
#define LT_OP 266
#define GT_OP 267
#define AND_OP 268
#define OR_OP 269
#define AUTO 270
#define SWITCH 271
#define CASE 272
#define UNION 273
#define EXTERN 274
#define REGISTER 275
#define STATIC 276
#define TYPEDEF 277
#define VOLATILE 278
#define INT 279
#define VOID 280
#define DOUBLE 281
#define CHAR 282
#define FLOAT 283
#define LONG 284
#define SHORT 285
#define SIGNED 286
#define UNSIGNED 287
#define STRUCT 288
#define DEFAULT 289
#define ENUM 290
#define IF 291
#define ELSE 292
#define WHILE 293
#define FOR 294
#define RETURN 295
#define BREAK 296
#define CONTINUE 297
#define DO 298
#define GOTO 299
#define IFX 300

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 6 "structfe.y"

        int num;
        char id;

#line 162 "y.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
