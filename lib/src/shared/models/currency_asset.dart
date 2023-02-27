enum CurrencyAsset {
  aPolUSDC(actualAsset: "aPolUSDC", shownAsset: "USDC"),
  mcUSD(actualAsset: "mcUSD", shownAsset: "cUSD");

  const CurrencyAsset({required this.actualAsset, required this.shownAsset});
  final String actualAsset;
  final String shownAsset;


}