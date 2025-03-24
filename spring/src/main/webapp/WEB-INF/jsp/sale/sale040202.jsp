<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > 장비판매현황-연간 > 전체집계 > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-09-21 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGridTop;
		var auiGridBom;

		var dataFieldNameTop = []; // 펼침 항목(create할때 넣음)
		var dataFieldNameBom = []; // 펼침 항목(create할때 넣음)

		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGridTop();
			createAUIGridBom();
			goSearch();
		});


		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGridTop, '장비판매현황_연간_메이커');
		}

		//엑셀다운로드
		function fnExcelDownSec() {
			fnExportExcel(auiGridBom, '장비판매현황_연간_월');
		}

		function goSearch() {

			var s_month =  $M.getValue("s_month");

			if(s_month.toString().length == 1) {
				s_month = '0' + s_month;
			};

			var param = {
				s_year_mon  : $M.getValue("s_year") + s_month,
				s_rental_yn : $M.getValue("s_rental_yn"),
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGridTop, result.topList);
						AUIGrid.setGridData(auiGridBom, result.bomList);
					};
				}
			);
		}

		//그리드생성
		function createAUIGridTop() {
			var gridPros = {
				rowIdField : "_$uid",
				showStateColumn : false,
				showRowNumColumn: false,
				showFooter : true,
				footerPosition : "top",
				editable : false,
				headerHeight : 20,
			};
			var columnLayout = [
				{
					headerText : "연도",
					dataField : "yearid",
					style : "aui-center",
					width : "60",
					minWidth : "30",
				},
				{
					headerText : "전체</br>합계",
					dataField : "all_tot_cnt",
					style : "aui-right",
					width : "55",
					minWidth : "25",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if(value == 0) {
							return "";
						};
						return $M.setComma(value);
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value != 0) {
							return "aui-popup"
						}
					},
				},
				{
					headerText : "본사</br>합계",
					dataField : "yk_tot_cnt",
					style : "aui-right",
					width : "55",
					minWidth : "25",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if(value == 0) {
							return "";
						};
						return $M.setComma(value);
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value != 0) {
							return "aui-popup"
						}
					},
				},
				{
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// headerText : "대리점</br>합계",
					headerText : "위탁판매점</br>합계",
					dataField : "etc_tot_cnt",
					style : "aui-right",
					width : "100",
					minWidth : "25",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if(value == 0) {
							return "";
						};
						return $M.setComma(value);
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value != 0) {
							return "aui-popup"
						}
					},
				},
				{
					headerText : "얀마",
					children : [
						{
							headerText : "소형",
							children : [
								{
									dataField : "yanmar_s_yk_cnt",
									headerText : "본사",
									width : "55",
									minWidth : "25",
									style : "aui-right",
									labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
										if(value == 0) {
											return "";
										};
										return $M.setComma(value);
									},
									styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
										if(value != 0) {
											return "aui-popup"
										};
									},
								},
								{
									dataField : "yanmar_s_etc_cnt",
									// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
									// headerText : "대리점",
									headerText : "위탁판매점",
									width : "100",
									minWidth : "25",
									headerStyle : "aui-fold",
									style : "aui-right",
									labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
										if(value == 0) {
											return "";
										};
										return $M.setComma(value);
									},
									styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
										if(value != 0) {
											return "aui-popup"
										};
									},
								},
								{
									dataField : "yanmar_s_tot_cnt",
									headerText : "소계",
									width : "55",
									minWidth : "25",
									headerStyle : "aui-fold",
									style : "aui-right",
									labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
										if(value == 0) {
											return "";
										};
										return $M.setComma(value);
									},
									styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
										if(value != 0) {
											return "aui-popup"
										}
									},
								}
							]
						},
						{
							headerText : "대형",
							children : [
								{
									dataField : "yanmar_l_yk_cnt",
									headerText : "본사",
									width : "55",
									minWidth : "25",
									style : "aui-right",
									labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
										if(value == 0) {
											return "";
										};
										return $M.setComma(value);
									},
									styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
										if(value != 0) {
											return "aui-popup"
										};
									},
								},
								{
									dataField : "yanmar_l_etc_cnt",
									// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
									// headerText : "대리점",
									headerText : "위탁판매점",
									width : "100",
									minWidth : "25",
									headerStyle : "aui-fold",
									style : "aui-right",
									labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
										if(value == 0) {
											return "";
										};
										return $M.setComma(value);
									},
									styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
										if(value != 0) {
											return "aui-popup"
										};
									},
								},
								{
									dataField : "yanmar_l_tot_cnt",
									headerText : "소계",
									width : "55",
									minWidth : "25",
									headerStyle : "aui-fold",
									style : "aui-right",
									labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
										if(value == 0) {
											return "";
										};
										return $M.setComma(value);
									},
									styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
										if(value != 0) {
											return "aui-popup"
										}
									},
								}
							]
						},
						{
							headerText : "계",
							children : [
								{
									dataField : "yanmar_yk_total_cnt",
									headerText : "본사",
									width : "55",
									minWidth : "25",
									style : "aui-right",
									labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
										if(value == 0) {
											return "";
										};
										return $M.setComma(value);
									},
									styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
										if(value != 0) {
											return "aui-popup"
										};
									},
								},
								{
									dataField : "yanmar_etc_total_cnt",
									// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
									// headerText : "대리점",
									headerText : "위탁판매점",
									width : "100",
									minWidth : "25",
									headerStyle : "aui-fold",
									style : "aui-right",
									labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
										if(value == 0) {
											return "";
										};
										return $M.setComma(value);
									},
									styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
										if(value != 0) {
											return "aui-popup"
										};
									},
								},
								{
									dataField : "yanmar_total_cnt",
									headerText : "소계",
									width : "55",
									minWidth : "25",
									headerStyle : "aui-fold",
									style : "aui-right",
									labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
										if(value == 0) {
											return "";
										};
										return $M.setComma(value);
									},
									styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
										if(value != 0) {
											return "aui-popup"
										}
									},
								}
							]
						}
					]
				},
				{
					headerText : "겔",
					children : [
						{
							dataField : "gel_yk_cnt",
							headerText : "본사",
							width : "55",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "gel_etc_cnt",
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점",
							headerText : "위탁판매점",
							width : "100",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "gel_tot_cnt",
							headerText : "소계",
							width : "55",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								}
							},
						}
					]
				},
				{
					headerText : "빌트겐",
					children : [
						{
							dataField : "wirtgen_yk_cnt",
							headerText : "본사",
							width : "55",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "wirtgen_etc_cnt",
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점",
							headerText : "위탁판매점",
							width : "100",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "wirtgen_tot_cnt",
							headerText : "소계",
							width : "55",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								}
							},
						}
					]
				},
				{
					headerText : "보겔",
					children : [
						{
							dataField : "vogel_yk_cnt",
							headerText : "본사",
							width : "55",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "vogel_etc_cnt",
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점",
							headerText : "위탁판매점",
							width : "100",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "vogel_tot_cnt",
							headerText : "소계",
							width : "55",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								}
							},
						}
					]
				},
				{
					headerText : "햄",
					children : [
						{
							dataField : "hamm_yk_cnt",
							headerText : "본사",
							width : "55",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "hamm_etc_cnt",
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점",
							headerText : "위탁판매점",
							width : "100",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "hamm_tot_cnt",
							headerText : "소계",
							width : "55",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								}
							},
						}
					]
				},
				{
					headerText : "마니또",
					children : [
						{
							dataField : "manito_yk_cnt",
							headerText : "본사",
							width : "55",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "manito_etc_cnt",
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점",
							headerText : "위탁판매점",
							width : "100",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "manito_tot_cnt",
							headerText : "소계",
							width : "55",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								}
							},
						}
					]
				},
				{
					dataField : "etc_cnt",
					headerText : "기타",
					width : "55",
					minWidth : "25",
					style : "aui-right",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if(value == 0) {
							return "";
						};
						return $M.setComma(value);
					},
// 					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
// 						if(value != 0) {
// 							return "aui-popup"
// 						};
// 					},
				},

			];


			// 푸터레이아웃
			var footerColumnLayout = [
				{
					labelText : "전체합계",
					positionField : "yearid",
				},
				{
					dataField : "all_tot_cnt",
					positionField : "all_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "yk_tot_cnt",
					positionField : "yk_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "etc_tot_cnt",
					positionField : "etc_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "yanmar_s_yk_cnt",
					positionField : "yanmar_s_yk_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "yanmar_s_etc_cnt",
					positionField : "yanmar_s_etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "yanmar_s_tot_cnt",
					positionField : "yanmar_s_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "yanmar_l_yk_cnt",
					positionField : "yanmar_l_yk_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "yanmar_l_etc_cnt",
					positionField : "yanmar_l_etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "yanmar_l_tot_cnt",
					positionField : "yanmar_l_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "yanmar_yk_total_cnt",
					positionField : "yanmar_yk_total_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "yanmar_etc_total_cnt",
					positionField : "yanmar_etc_total_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "yanmar_total_cnt",
					positionField : "yanmar_total_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},

				{
					dataField : "gel_yk_cnt",
					positionField : "gel_yk_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "gel_etc_cnt",
					positionField : "gel_etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "gel_tot_cnt",
					positionField : "gel_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},

				{
					dataField : "wirtgen_yk_cnt",
					positionField : "wirtgen_yk_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "wirtgen_etc_cnt",
					positionField : "wirtgen_etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "wirtgen_tot_cnt",
					positionField : "wirtgen_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},

				{
					dataField : "vogel_yk_cnt",
					positionField : "vogel_yk_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "vogel_etc_cnt",
					positionField : "vogel_etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "vogel_tot_cnt",
					positionField : "vogel_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},

				{
					dataField : "hamm_yk_cnt",
					positionField : "hamm_yk_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "hamm_etc_cnt",
					positionField : "hamm_etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "hamm_tot_cnt",
					positionField : "hamm_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},

				{
					dataField : "manito_yk_cnt",
					positionField : "manito_yk_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "manito_etc_cnt",
					positionField : "manito_etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "manito_tot_cnt",
					positionField : "manito_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},

				{
					dataField : "etc_cnt",
					positionField : "etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
			];

			auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
			AUIGrid.setFooter(auiGridTop, footerColumnLayout);
			AUIGrid.setGridData(auiGridTop, []);
			$("#auiGridTop").resize();

			AUIGrid.bind(auiGridTop, "cellClick", function(event) {
				if(event.dataField != "yearid" && event.dataField != "etc_cnt") {
					var eventValue = $M.nvl(event.value, 0);

					if(eventValue == 0) {
						return;
					};

					var s_year 	=  $M.getValue("s_year");
					var s_month =  $M.getValue("s_month");
					var year  	= event.item.yearid;

					if(s_month.toString().length == 1) {
						s_month = '0' + s_month;
					};

					var startMon = '01';
					var endMon 	 = '12';

					if(s_year == year) {
						endMon = s_month;
					};

					var yearMonSt 	= year + startMon;
					var yearMonEd 	= year + endMon;
					var makerCd 	= "";		// 메이커 구분
					var orgGubun 	= ""; 		// 본사:01, 대리점:02
					var weightType  = "";		// 규격 S:소형 L:대형

					if(event.headerText.indexOf("본사") > -1) {
						// 본사
						orgGubun = '01';
						// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
						// } else if(event.headerText == "대리점") {
					} else if(event.headerText.indexOf("위탁판매점") > -1) {
						// 대리점
						orgGubun = '02';
					};

					if(event.dataField.indexOf("yk_tot_") < 0  && event.dataField.indexOf("etc_tot_") < 0 ) {
						if (event.dataField.indexOf("yanmar") != -1) {
							makerCd = "27";
							if (event.dataField.indexOf("yanmar_l") != -1) {
								weightType = "L";
							} else if (event.dataField.indexOf("yanmar_s") != -1) {
								weightType = "S";
							}
							;
						} else if (event.dataField.substring(0, 3) == "gel") {
							makerCd = "02";
						} else if (event.dataField.indexOf("wirtgen") != -1) {
							makerCd = "94";
						} else if (event.dataField.substring(0, 5) == "vogel") {
							makerCd = "101";
						} else if (event.dataField.indexOf("hamm") != -1) {
							makerCd = "42";
						} else if (event.dataField.indexOf("manito") != -1) {
							makerCd = "68";
						} else if (event.dataField.indexOf("etc") != -1) {
							makerCd = "46";
						};
					}

					if($M.toNum(event.item.yearid) <= $M.toNum(2007)) {
						alert("2008년 이전 데이터는 열람이 불가능합니다.");
						return;
					};

					var params = {
						year_mon_st  		: yearMonSt,
						year_mon_ed  		: yearMonEd,
						org_gubun 	 		: orgGubun,
						maker_cd 	 		: makerCd,
						maker_weight_type 	: weightType,
						rental_yn 	 		: $M.getValue("s_rental_yn"),
					}

					var popupOption = "";
					$M.goNextPage('/sale/sale0402p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});

			// 펼치기 전에 접힐 컬럼 목록
			var auiColList = AUIGrid.getColumnInfoList(auiGridTop);
			for (var i = 0; i <auiColList.length; ++i) {
				if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
					dataFieldNameTop.push(auiColList[i].dataField);
				}
			}

			for (var i = 0; i < dataFieldNameTop.length; ++i) {
				var dataField = dataFieldNameTop[i];
				AUIGrid.hideColumnByDataField(auiGridTop, dataField);
			}
		}

		//그리드생성
		function createAUIGridBom() {
			var gridPros = {
				rowIdField : "_$uid",
				showStateColumn : false,
				showRowNumColumn: false,
				showFooter : true,
				footerPosition : "top",
				editable : false,
			};
			var columnLayout = [
				{
					headerText : "연도",
					dataField : "yearid",
					width : "60",
					minWidth : "30",
					style : "aui-center"
				},
				{
					headerText : "전체</br>합계",
					dataField : "all_tot_cnt",
					style : "aui-right",
					width : "55",
					minWidth : "25",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if(value == 0) {
							return "";
						};
						return $M.setComma(value);
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value != 0) {
							return "aui-popup"
						}
					},
				},
				{
					headerText : "본사</br>합계",
					dataField : "yk_tot_cnt",
					style : "aui-right",
					width : "55",
					minWidth : "25",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if(value == 0) {
							return "";
						};
						return $M.setComma(value);
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value != 0) {
							return "aui-popup"
						}
					},
				},
				{
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// headerText : "대리점</br>합계",
					headerText : "위탁판매점</br>합계",
					dataField : "etc_tot_cnt",
					style : "aui-right",
					width : "100",
					minWidth : "25",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if(value == 0) {
							return "";
						};
						return $M.setComma(value);
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value != 0) {
							return "aui-popup"
						}
					},
				},
				{
					headerText : "01월",
					children : [
						{
							dataField : "month01_yk_cnt",
							headerText : "본사",
							width : "55",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month01_etc_cnt",
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점",
							headerText : "위탁판매점",
							width : "100",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month01_tot_cnt",
							headerText : "소계",
							width : "55",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								}
							},
						},
					]
				},
				{
					headerText : "02월",
					children : [
						{
							dataField : "month02_yk_cnt",
							headerText : "본사",
							width : "55",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month02_etc_cnt",
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점",
							headerText : "위탁판매점",
							width : "100",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month02_tot_cnt",
							headerText : "소계",
							width : "55",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								}
							},
						},
					]
				},
				{
					headerText : "03월",
					children : [
						{
							dataField : "month03_yk_cnt",
							headerText : "본사",
							width : "55",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month03_etc_cnt",
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점",
							headerText : "위탁판매점",
							width : "100",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month03_tot_cnt",
							headerText : "소계",
							width : "55",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								}
							},
						},
					]
				},
				{
					headerText : "04월",
					children : [
						{
							dataField : "month04_yk_cnt",
							headerText : "본사",
							width : "55",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month04_etc_cnt",
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점",
							headerText : "위탁판매점",
							width : "100",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month04_tot_cnt",
							headerText : "소계",
							width : "55",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								}
							},
						},
					]
				},
				{
					headerText : "05월",
					children : [
						{
							dataField : "month05_yk_cnt",
							headerText : "본사",
							width : "55",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month05_etc_cnt",
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점",
							headerText : "위탁판매점",
							width : "100",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup";
								};
							},
						},
						{
							dataField : "month05_tot_cnt",
							headerText : "소계",
							width : "55",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								}
							},
						},
					]
				},
				{
					headerText : "06월",
					children : [
						{
							dataField : "month06_yk_cnt",
							headerText : "본사",
							width : "55",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month06_etc_cnt",
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점",
							headerText : "위탁판매점",
							width : "100",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month06_tot_cnt",
							headerText : "소계",
							width : "55",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								}
							},
						},
					]
				},
				{
					headerText : "07월",
					children : [
						{
							dataField : "month07_yk_cnt",
							headerText : "본사",
							width : "55",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month07_etc_cnt",
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점",
							headerText : "위탁판매점",
							width : "100",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month07_tot_cnt",
							headerText : "소계",
							width : "55",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								}
							},
						},
					]
				},
				{
					headerText : "08월",
					children : [
						{
							dataField : "month08_yk_cnt",
							headerText : "본사",
							width : "55",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month08_etc_cnt",
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점",
							headerText : "위탁판매점",
							width : "100",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month08_tot_cnt",
							headerText : "소계",
							width : "55",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								}
							},
						},
					]
				},
				{
					headerText : "09월",
					children : [
						{
							dataField : "month09_yk_cnt",
							headerText : "본사",
							width : "55",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month09_etc_cnt",
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점",
							headerText : "위탁판매점",
							width : "100",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month09_tot_cnt",
							headerText : "소계",
							width : "55",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								}
							},
						},
					]
				},
				{
					headerText : "10월",
					children : [
						{
							dataField : "month10_yk_cnt",
							headerText : "본사",
							width : "55",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month10_etc_cnt",
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점",
							headerText : "위탁판매점",
							width : "100",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month10_tot_cnt",
							headerText : "소계",
							width : "55",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								}
							},
						},
					]
				},
				{
					headerText : "11월",
					children : [
						{
							dataField : "month11_yk_cnt",
							headerText : "본사",
							width : "55",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month11_etc_cnt",
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점",
							headerText : "위탁판매점",
							width : "100",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month11_tot_cnt",
							headerText : "소계",
							width : "55",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								}
							},
						},
					]
				},
				{
					headerText : "12월",
					children : [
						{
							dataField : "month12_yk_cnt",
							headerText : "본사",
							width : "55",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month12_etc_cnt",
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점",
							headerText : "위탁판매점",
							width : "100",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								};
							},
						},
						{
							dataField : "month12_tot_cnt",
							headerText : "소계",
							width : "55",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if(value == 0) {
									return "";
								};
								return $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"
								}
							},
						},
					]
				},

			];

			// 푸터레이아웃
			var footerColumnLayout = [
				{
					labelText : "전체합계",
					positionField : "yearid",
				},
				{
					dataField : "all_tot_cnt",
					positionField : "all_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "yk_tot_cnt",
					positionField : "yk_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "etc_tot_cnt",
					positionField : "etc_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month01_yk_cnt",
					positionField : "month01_yk_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month01_etc_cnt",
					positionField : "month01_etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month01_tot_cnt",
					positionField : "month01_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},

				{
					dataField : "month02_yk_cnt",
					positionField : "month02_yk_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month02_etc_cnt",
					positionField : "month02_etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month02_tot_cnt",
					positionField : "month02_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},

				{
					dataField : "month03_yk_cnt",
					positionField : "month03_yk_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month03_etc_cnt",
					positionField : "month03_etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month03_tot_cnt",
					positionField : "month03_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},

				{
					dataField : "month04_yk_cnt",
					positionField : "month04_yk_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month04_etc_cnt",
					positionField : "month04_etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month04_tot_cnt",
					positionField : "month04_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},

				{
					dataField : "month05_yk_cnt",
					positionField : "month05_yk_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month05_etc_cnt",
					positionField : "month05_etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month05_tot_cnt",
					positionField : "month05_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},

				{
					dataField : "month06_yk_cnt",
					positionField : "month06_yk_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month06_etc_cnt",
					positionField : "month06_etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month06_tot_cnt",
					positionField : "month06_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},

				{
					dataField : "month07_yk_cnt",
					positionField : "month07_yk_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month07_etc_cnt",
					positionField : "month07_etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month07_tot_cnt",
					positionField : "month07_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},

				{
					dataField : "month08_yk_cnt",
					positionField : "month08_yk_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month08_etc_cnt",
					positionField : "month08_etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month08_tot_cnt",
					positionField : "month08_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},

				{
					dataField : "month09_yk_cnt",
					positionField : "month09_yk_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month09_etc_cnt",
					positionField : "month09_etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month09_tot_cnt",
					positionField : "month09_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},

				{
					dataField : "month10_yk_cnt",
					positionField : "month10_yk_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month10_etc_cnt",
					positionField : "month10_etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month10_tot_cnt",
					positionField : "month10_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},

				{
					dataField : "month11_yk_cnt",
					positionField : "month11_yk_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month11_etc_cnt",
					positionField : "month11_etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month11_tot_cnt",
					positionField : "month11_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},

				{
					dataField : "month12_yk_cnt",
					positionField : "month12_yk_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month12_etc_cnt",
					positionField : "month12_etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month12_tot_cnt",
					positionField : "month12_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
			];

			auiGridBom = AUIGrid.create("#auiGridBom", columnLayout, gridPros);
			AUIGrid.setFooter(auiGridBom, footerColumnLayout);
			AUIGrid.setGridData(auiGridBom, []);
			$("#auiGridBom").resize();

			AUIGrid.bind(auiGridBom, "cellClick", function(event) {
				if(event.dataField != "yearid") {
					var eventValue = $M.nvl(event.value, 0);

					if(eventValue == 0) {
						return;
					};

					if($M.toNum(event.item.yearid) <= $M.toNum(2007)) {
						alert("2008년 이전 데이터는 열람이 불가능합니다.");
						return;
					};

					var org_gubun 	= ""; 		// 본사:01, 지사:02 구분

					var year  =  event.item.yearid;
					var month =  event.dataField.substring(5, 7);

					debugger;
					if(event.dataField.indexOf("yk_") > -1) {
						org_gubun = '01';
					} else if(event.dataField.indexOf("etc_") > -1) {
						org_gubun = '02';
					}

					var params = {
						year_mon  : year + month,
						rental_yn : $M.getValue("s_rental_yn"),
						org_gubun : org_gubun,
					};
					if (event.dataField == "all_tot_cnt" || event.dataField == "yk_tot_cnt" || event.dataField == "etc_tot_cnt") {
						params.year_mon = "";
						params.year_mon_st = year + "01";
						params.year_mon_ed = year + "12";
					}

					var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=710, left=0, top=0";
					$M.goNextPage('/sale/sale0402p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});

			// 펼치기 전에 접힐 컬럼 목록
			var auiColList = AUIGrid.getColumnInfoList(auiGridBom);
			for (var i = 0; i <auiColList.length; ++i) {
				if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
					dataFieldNameBom.push(auiColList[i].dataField);
				}
			}

			for (var i = 0; i < dataFieldNameBom.length; ++i) {
				var dataField = dataFieldNameBom[i];
				AUIGrid.hideColumnByDataField(auiGridBom, dataField);
			}
		}

		// 펼침
		function fnChangeColumn(event) {
			var data = AUIGrid.getGridData(auiGridTop);
			var target = event.target || event.srcElement;
			if(!target)	return;

			var dataField = target.value;
			var checked = target.checked;

			for (var i = 0; i < dataFieldNameTop.length; ++i) {
				var dataField = dataFieldNameTop[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGridTop, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGridTop, dataField);
				}
			}

			for (var i = 0; i < dataFieldNameBom.length; ++i) {
				var dataField = dataFieldNameBom[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGridBom, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGridBom, dataField);
				}
			}

			// 구해진 칼럼 사이즈를 적용 시킴.
// 			var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
// 		    AUIGrid.setColumnSizeList(auiGrid, colSizeList);
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<!-- 메인 타이틀 -->
				<!-- 				<div class="main-title"> -->
				<!-- 					<h2>장비판매현황-전체</h2> -->
				<!-- 				</div> -->
				<!-- /메인 타이틀 -->
				<div class="contents">
					<!-- 					<ul class="tabs-c"> -->
					<!-- 						<li class="tabs-item"> -->
					<!-- 							<a href="#" class="tabs-link font-12">연간집계</a> -->
					<!-- 						</li> -->
					<!-- 						<li class="tabs-item"> -->
					<!-- 							<a href="#" class="tabs-link font-12 active">전체집계</a> -->
					<!-- 						</li> -->
					<!-- 					</ul> -->
					<!-- 기본 -->
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="150px">
								<col width="95px">
								<col width="*">
							</colgroup>
							<tbody>
							<tr>
								<th>조회년월</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-7">
											<select class="form-control width120px" name="s_year" id="s_year">
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year+5}" step="1">
													<option value="${i}" <c:if test="${i eq inputParam.s_current_year}">selected="selected"</c:if>>${i}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-5">
											<select class="form-control width120px" name="s_month" id="s_month">
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="${i}" <c:if test="${i eq fn:substring(inputParam.s_current_mon, 4, 6)}">selected="selected"</c:if>>${i}월</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
								<td class="pl15">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" name="s_rental_yn" id="s_rental_yn" value="Y" checked="checked" onchange="goSearch();">
										<label class="form-check-label">렌탈포함</label>
									</div>
								</td>
								<td class="">
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /기본 -->
					<!-- 메이커별 조회결과 -->
					<div class="title-wrap mt10">
						<h4>메이커별 조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<label for="s_toggle_column" style="color:black;">
									<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
								</label>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<div style="margin-top: 5px; height: 400px;" id="auiGridTop" ></div>
					<!-- /메이커별 조회결과 -->
					<!-- 월별 조회결과 -->
					<div class="title-wrap mt10">
						<h4>월별 조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
					<div style="margin-top: 5px; height: 400px; " id="auiGridBom"></div>
					<!-- /월별 조회결과 -->
				</div>

			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>
