-- CreateEnum
CREATE TYPE "public"."ReactionType" AS ENUM ('FIRE', 'THUMBS_UP');

-- CreateTable
CREATE TABLE "public"."brotherhood_posts" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "text" TEXT NOT NULL,
    "topic" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "brotherhood_posts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."brotherhood_replies" (
    "id" TEXT NOT NULL,
    "postId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "text" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "brotherhood_replies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."brotherhood_reactions" (
    "id" TEXT NOT NULL,
    "postId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" "public"."ReactionType" NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "brotherhood_reactions_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "brotherhood_posts_userId_idx" ON "public"."brotherhood_posts"("userId");

-- CreateIndex
CREATE INDEX "brotherhood_posts_topic_idx" ON "public"."brotherhood_posts"("topic");

-- CreateIndex
CREATE INDEX "brotherhood_replies_postId_idx" ON "public"."brotherhood_replies"("postId");

-- CreateIndex
CREATE INDEX "brotherhood_replies_userId_idx" ON "public"."brotherhood_replies"("userId");

-- CreateIndex
CREATE INDEX "brotherhood_reactions_postId_idx" ON "public"."brotherhood_reactions"("postId");

-- CreateIndex
CREATE INDEX "brotherhood_reactions_userId_idx" ON "public"."brotherhood_reactions"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "brotherhood_reactions_postId_userId_type_key" ON "public"."brotherhood_reactions"("postId", "userId", "type");

-- AddForeignKey
ALTER TABLE "public"."brotherhood_posts" ADD CONSTRAINT "brotherhood_posts_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."brotherhood_replies" ADD CONSTRAINT "brotherhood_replies_postId_fkey" FOREIGN KEY ("postId") REFERENCES "public"."brotherhood_posts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."brotherhood_replies" ADD CONSTRAINT "brotherhood_replies_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."brotherhood_reactions" ADD CONSTRAINT "brotherhood_reactions_postId_fkey" FOREIGN KEY ("postId") REFERENCES "public"."brotherhood_posts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."brotherhood_reactions" ADD CONSTRAINT "brotherhood_reactions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
