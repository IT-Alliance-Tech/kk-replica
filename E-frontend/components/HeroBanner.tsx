"use client";
import { useEffect, useState } from "react";
import Image from "next/image";
import { createClientComponentClient } from "@supabase/auth-helpers-nextjs";

export default function HeroBanner() {
  const [banner, setBanner] = useState<any>(null);
  const supabase = createClientComponentClient();

  useEffect(() => {
    const fetchBanner = async () => {
      const { data } = await supabase
        .from("banners")
        .select("*")
        .order("created_at", { ascending: false })
        .limit(1)
        .single();
      setBanner(data);
    };
    fetchBanner();
    // supabase client is stable, safe to omit from deps
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  if (!banner) return null;

  return (
    <div className="w-full h-[250px] sm:h-[300px] md:h-[400px] lg:h-[450px] relative rounded-lg sm:rounded-xl overflow-hidden">
      {/* TODO: replace with next/image if src is static */}
      <Image
        src={banner.image_url}
        alt="Hero Banner"
        fill
        className="w-full h-full object-cover"
      />
      <div className="absolute inset-0 flex items-center justify-center">
        <div className="text-center text-white max-w-[80%] sm:max-w-[70%] md:max-w-[60%]">
          <h1 className="text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-extrabold leading-tight drop-shadow-lg">
            {banner.title}
          </h1>
          <p className="text-base sm:text-lg md:text-xl text-white/90 mt-3 drop-shadow-md">
            {banner.subtitle}
          </p>
        </div>
      </div>
    </div>
  );
}
