#pragma once
#include "./expr.h"

namespace hint
{
struct Hint
{
    std::string text;
    std::string note;
};

using Hints = std::vector<Hint>;

std::optional<antlr4::tree::ParseTree *> getTreeFromPos(antlr4::tree::ParseTree *root,
                                                        size_t charPosInLine, size_t line);

Hints completion(antlr4::Parser *parser, antlr4::tree::ParseTree *caret);

}  // namespace hint
