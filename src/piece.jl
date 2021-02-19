import Base.<, Base.>

export PieceColor, PieceType, Piece

export colorfromchar,
    coloropp,
    isok,
    isslider,
    pcolor,
    piecefromchar,
    piecetypefromchar,
    ptype,
    tochar,
    tounicode
export BISHOP,
    BLACK,
    COLOR_NONE,
    EMPTY,
    KING,
    KNIGHT,
    PAWN,
    PIECE_BB,
    PIECE_BK,
    PIECE_BN,
    PIECE_BP,
    PIECE_BQ,
    PIECE_BR,
    PIECE_TYPE_NONE,
    PIECE_WB,
    PIECE_WK,
    PIECE_WN,
    PIECE_WP,
    PIECE_WQ,
    PIECE_WR,
    QUEEN,
    ROOK,
    WHITE


"""
    PieceColor

Type representing the color of a chess piece.
"""
abstract type PieceColor end
"""
    White

Type representing white pieces
"""
struct White <: PieceColor end
"""
    Black

Type representing black pieces
"""
struct Black <: PieceColor end


"""
    coloropp(c::PieceColor)

Returns the opposite of a color.

# Examples

```julia-repl
julia> coloropp(White) == Black
true

julia> coloropp(Black) == White
true
```
"""
coloropp(::Type{<:Black}) = White
coloropp(::Type{<:White}) = Black
coloropp(::P) where {P<:PieceColor} = coloropp(P)



"""
    colorfromchar(c::Char)

Tries to convert a character to a `PieceColor`.

The return value is a `Union{PieceColor, Nothing}`. If the input character is
one of the four characters `'w'`, `'b'`, `'W'`, `'B'`, the function returns the
obvious corresponding color (`WHITE` or `BLACK`). For all other input
characters, the function returns `nothing`.

# Examples

```julia-repl
julia> colorfromchar('w') == WHITE
true

julia> colorfromchar('B') == BLACK
true

julia> colorfromchar('x') == nothing
true
```
"""
function Base.parse(::Type{PieceColor}, c::Char)
    k = lowercase(c)
    if k == 'w'
        return White
    elseif k == 'b'
        return Black
    else
        throw(ArgumentError("invalid piece color $c"))
    end
end


"""
    tochar(c::PieceColor)

Converts a color to a character.

# Examples

```julia-repl
julia> tochar(WHITE)
'w': ASCII/Unicode U+0077 (category Ll: Letter, lowercase)

julia> tochar(BLACK)
'b': ASCII/Unicode U+0062 (category Ll: Letter, lowercase)

julia> tochar(COLOR_NONE)
'?': ASCII/Unicode U+003f (category Po: Punctuation, other)
```
"""
Base.convert(::Type{C}, ::Type{White}) where {C<:AbstractChar} = C('w')
Base.convert(::Type{C}, ::Type{Black}) where {C<:AbstractChar} = C('b')


"""
    PieceType

Type representing the type of a chess piece.

This is essentially a piece without color. The possible values are `PAWN`,
`KNIGHT`, `BISHOP`, `ROOK`, `QUEEN`, `KING` and `PIECE_TYPE_NONE`. The reason
for the existence of the value `PIECE_TYPE_NONE` is that we represent a chess
board as an array of pieces, and we need a special `Piece` value `EMPTY` to
indicate an empty square on the board. The type of the `EMPTY` piece is
`PIECE_TYPE_NONE`
"""
abstract type PieceType end
struct Pawn <: PieceType end
struct Knight <: PieceType end
struct Bishop <: PieceType end
struct Rook <: PieceType end
struct Queen <: PieceType end
struct King <: PieceType end

Base.convert(::Type{T}, ::Type{Pawn}) where {T<:Number} = T(1)
Base.convert(::Type{T}, ::Type{Knight}) where {T<:Number} = T(3)
Base.convert(::Type{T}, ::Type{Bishop}) where {T<:Number} = T(3)
Base.convert(::Type{T}, ::Type{Rook}) where {T<:Number} = T(5)
Base.convert(::Type{T}, ::Type{Queen}) where {T<:Number} = T(9)
Base.convert(::Type{T}, ::Type{King}) where {T<:Number} = typemax(T)

(<)(::Type{T1}, ::Type{T2}) where {T1<:PieceType,T2<:PieceType} = convert(Int, T1) < convert(Int, T2)
(<)(::Knight, ::Bishop) = true
(<)(::Bishop, ::Knight) = false


"""
    piecetypefromchar(c::Chars)

Tries to convert a character to a `PieceType`.

The return value is a `Union{PieceType, Nothing}`. If the input character is a
valid upper- or lowercase English piece letter (PNBRQK), the function returns
the corresponding piece type. For all other input characters, the function
returns `nothing`.

# Examples

```julia-repl
julia> piecetypefromchar('n') == KNIGHT
true

julia> piecetypefromchar('B') == BISHOP
true

julia> piecetypefromchar('a') == nothing
true
```
"""
function Base.parse(::Type{PieceType}, c::Char)
    k = lowercase(c)
    if k == 'p'
        return Pawn
    elseif k == 'n'
        return Knight
    elseif k == 'b'
        return Bishop
    elseif k == 'r'
        return Rook
    elseif k == 'q'
        return Queen
    elseif k == 'k'
        return King
    else
        throw(ArgumentError("invalid piece type $k"))
    end
end


"""
    tochar(t::PieceType, uppercase = false)

Converts a `PieceType` value to a character.

A valid piece type value is converted to its standard English algebraic
notation piece letter. Any invalid piece type value is converted to a `'?'`
character. The optional parameter `uppercase` controls whether the character
is an upper- or lower-case letter.

# Examples

```julia-repl
julia> tochar(PAWN)
'p': ASCII/Unicode U+0070 (category Ll: Letter, lowercase)

julia> tochar(ROOK, true)
'R': ASCII/Unicode U+0052 (category Lu: Letter, uppercase)

julia> tochar(PIECE_TYPE_NONE)
'?': ASCII/Unicode U+003f (category Po: Punctuation, other)
```
"""
convert(::AbstractChar, ::Pawn) = 'p'
convert(::AbstractChar, ::Knight) = 'n'
convert(::AbstractChar, ::Bishop) = 'b'
convert(::AbstractChar, ::Rook) = 'r'
convert(::AbstractChar, ::Queen) = 'q'
convert(::AbstractChar, ::King) = 'k'


"""
    Piece

Type representing a chess piece.
"""
struct Piece{C<:PieceColor,T<:PieceType} end

"""
    Piece(c::PieceColor, t::PieceType)

Construct a piece with the given color and type.

# Examples
```julia-repl
julia> Piece(Black, Queen)
Black Queen
```
"""
Piece(::Type{C}, ::Type{T}) where {C<:PieceColor, T<:PieceType} = Piece{C,T}()

Base.show(io::IO, p::Piece{C,T}) where {C,T} = print(io, "$C $T")

piececolor(::Piece{C}) where {C} = C
piecetype(::Piece{C,T}) where {C,T} = T


function Base.parse(::Type{Piece}, c::Char)
    color = isuppercase(c) ? White : Black
    type = parse(PieceType, c)
    Piece(color, type)
end

"""
    tochar(p::Piece)

Converts a piece to a character.

# Examples

```julia-repl
julia> tochar(PIECE_WN)
'N': ASCII/Unicode U+004e (category Lu: Letter, uppercase)

julia> tochar(PIECE_BK)
'k': ASCII/Unicode U+006b (category Ll: Letter, lowercase)

julia> tochar(EMPTY)
'?': ASCII/Unicode U+003f (category Po: Punctuation, other)
```
"""
function Base.convert(::Type{C}, p::Piece{Black,T}) where {C<:AbstractChar,T}
    char = convert(C, T)
    return uppercase(char)
end
function Base.convert(::Type{C}, p::Piece{White,T}) where {C<:AbstractChar,T}
    return convert(C, T)
end

function tounicode(p::Piece)::Char
    chars = ['♙', '♘', '♗', '♖', '♕', '♔', '?', '?', '♟', '♞', '♝', '♜', '♛', '♚']
    if isok(p)
        chars[p.val]
    else
        '?'
    end
end


"""
    isslider(t::PieceType)
    isslider(p::Piece)

Determine whether a piece is a sliding piece.
"""
const IsSlider = Union{Bishop, Queen}
