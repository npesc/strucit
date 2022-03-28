/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

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

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     IDENTIFIER = 258,
     CONSTANT = 259,
     SIZEOF = 260,
     PTR_OP = 261,
     LE_OP = 262,
     GE_OP = 263,
     EQ_OP = 264,
     NE_OP = 265,
     LT_OP = 266,
     GT_OP = 267,
     AND_OP = 268,
     OR_OP = 269,
     AUTO = 270,
     SWITCH = 271,
     CASE = 272,
     UNION = 273,
     EXTERN = 274,
     REGISTER = 275,
     STATIC = 276,
     TYPEDEF = 277,
     VOLATILE = 278,
     INT = 279,
     VOID = 280,
     DOUBLE = 281,
     CHAR = 282,
     FLOAT = 283,
     LONG = 284,
     SHORT = 285,
     SIGNED = 286,
     UNSIGNED = 287,
     STRUCT = 288,
     DEFAULT = 289,
     ENUM = 290,
     IF = 291,
     ELSE = 292,
     WHILE = 293,
     FOR = 294,
     RETURN = 295,
     BREAK = 296,
     CONTINUE = 297,
     DO = 298,
     GOTO = 299,
     IFX = 300
   };
#endif
/* Tokens.  */
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




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 6 "structfe.y"
{
        int num;
        char id;
}
/* Line 1529 of yacc.c.  */
#line 144 "y.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

