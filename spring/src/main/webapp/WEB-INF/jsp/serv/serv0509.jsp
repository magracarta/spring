<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 전국 Network현황 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2021-07-22 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <style type="text/css">

        /* 커스텀 행 스타일 ( 세로선 ) */
        .my-column-style {
            border-right: 3px solid #000000 !important;
        }

    </style>
    <script type="text/javascript">
        var auiGridFull; // 전부 펼쳐진 그리드
        var auiGridHalf; // 숨김 처리된 그리드

        $(document).ready(function () {
            createAUIGridFull();
            createAUIGridHalf();
            goSearch();
        });

        // 조회
        function goSearch() {
            var msMon = fnSetYearMon($M.getValue("s_year"), $M.getValue("s_mon"));
            var param = {
                s_ms_mon: msMon,
                s_org_code: $M.getValue("s_org_code"),
                s_detail_yn: $M.getValue("s_detail_yn") == "Y" ? "Y" : "N",
                s_masking_yn : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
            };

            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'get'},
                function (result) {
                    if (result.success) {
                    	var start_mon = $M.getValue("s_mon");
                    	var monStr = "";
                    	for(var i=2;i>=0;i--){
                    		var now = start_mon - i;
                    		if(now <= 0){
                    			now += 12;
                    		}
                    		monStr = monStr + now + "월,";
                    	}
                    	monStr = monStr.substr(0,monStr.length-1);
                    	var yearStr = "";
                    	var shortYearStr = "";
                    	if(start_mon == 12){
                    		yearStr += $M.getValue("s_year")+"년 1월 ~ "+$M.getValue("s_year")+"년 12월";
                    		shortYearStr += $M.getValue("s_year").substr(2,4)+"-1 ~ "+$M.getValue("s_year").substr(2,4)+"-12";
                    	}else{
                    		yearStr += $M.getValue("s_year")-1+"년 "+($M.toNum($M.getValue("s_mon"))+1)+"월 ~ "+$M.getValue("s_year")+"년 "+$M.getValue("s_mon")+"월";
                    		shortYearStr += ($M.getValue("s_year")-1).toString().substr(2,4)+"-"+($M.toNum($M.getValue("s_mon"))+1)+" ~ "+$M.getValue("s_year").substr(2,4)+"-"+$M.getValue("s_mon");
                    	}

                    	AUIGrid.setColumnPropByDataField(auiGridHalf, "and3Mon", {
                            headerText: "과 3개월("+monStr+")",
                        });
                    	AUIGrid.setColumnPropByDataField(auiGridHalf, "and1Year", {
                            headerText: "과 1년("+yearStr+")",
                        });
                    	AUIGrid.setColumnPropByDataField(auiGridFull, "and3Mon", {
                            headerText: "과 3개월("+monStr+")",
                        });
                    	AUIGrid.setColumnPropByDataField(auiGridFull, "and1Year", {
                            headerText: "과 1년("+yearStr+")",
                        });
                    	AUIGrid.setColumnPropByDataField(auiGridHalf, "tot_year_cnt", {
                            headerText: "과1년<br>계약합계<br>("+shortYearStr+")",
                        });
                    	AUIGrid.setColumnPropByDataField(auiGridFull, "tot_year_cnt", {
                            headerText: "과1년<br>계약합계<br>("+shortYearStr+")",
                        });
                    	AUIGrid.setColumnPropByDataField(auiGridHalf, "thr_mon_cnt", {
                            headerText: "과 3개월<br>계약대수<br>("+monStr+")",
                        });
                    	AUIGrid.setColumnPropByDataField(auiGridFull, "thr_mon_cnt", {
                            headerText: "과 3개월<br>계약대수<br>("+monStr+")",
                        });
                    	AUIGrid.setColumnPropByDataField(auiGridHalf, "year_mon_cnt", {
                            headerText: "과 1년<br>판매대수<br>("+shortYearStr+")",
                        });
                    	AUIGrid.setColumnPropByDataField(auiGridFull, "year_mon_cnt", {
                            headerText: "과 1년<br>판매대수<br>("+shortYearStr+")",
                        });

						$M.setValue("and3MonStr",monStr);
						$M.setValue("and1YearStr",yearStr);

                        AUIGrid.setGridData(auiGridFull, result.list);
                        AUIGrid.setGridData(auiGridHalf, result.list);

                        AUIGrid.refresh(auiGridFull);
                        AUIGrid.refresh(auiGridHalf);
                    }
                }
            );
        }

        // 날짜 Setting
        function fnSetYearMon(year, mon) {
            return year + (mon.length == 1 ? "0" + mon : mon);
        }

        // 지역별 대리점 개설 분포 현황
        function goDataSearch() {
            var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=840, left=0, top=0";
            var params = {};
            $M.goNextPage('/serv/serv0509p01', $M.toGetParam(params), {popupStatus: popupOption});
        }

        // 엑셀다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGridFull, "전국 Network현황");
        }

		// 절반정보 그리드 생성
		function createAUIGridHalf() {

			var gridPros = {
				// rowIdField 설정
				rowIdField: "_$uid",
				showRowNumColumn: false,
				enableCellMerge: true, // 셀병합 사용여부
				rowStyleFunction: function (rowIndex, item) {
				    console.log(item);
					if (item.org_name != "센터" && item.area_do == "전체합계") {
						return "aui-as-center-row-style";
					} else if (item.org_name == "센터" && item.area_do == "전체합계") {
						return "aui-as-tot-row-style";
					}
					return "";
				},
                // [15324] 틀 고정
                fixedColumnCount : 3
			};

			var columnLayout = [
				{
					headerText: "센터",
					dataField: "org_name",
					width: "70",
					minWidth: "60",
					cellColMerge: true, // 셀 가로 병합 실행
					cellColSpan: 3, // 셀 가로 병합 대상은 3개로 설정
					cellMerge: true,
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (item.area_do == "전체합계") {
							return "[" + value + "]";
						}
						return value;
					}
				},
				{
					headerText: "권역",
					dataField: "area_do",
					width: "60",
					minWidth: "50",
					cellMerge: true, // 구분1 셀 세로 병합 실행
					mergeRef: "org_name", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy: "restrict"
				},
				{
					headerText: "시/군",
					dataField: "area_si",
					width: "60",
					minWidth: "50",
					cellMerge: true, // 구분1 셀 세로 병합 실행
					mergeRef: "org_name", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy: "restrict"
				},
				{
					headerText: "서비스<br>고객수",
					dataField: "tot_cust_cnt",
					width: "60",
					minWidth: "50",
					cellMerge : true,
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 || value == null ? "" : $M.setComma(value);
					}
				},
				{
					headerText: "과 3개월",
					dataField: "and3Mon",
					children: [
						{
							headerText: "전체",
							dataField: "month_total_cnt",
							width: "60",
							minWidth: "50",
							cellMerge: true,
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : $M.setComma(value);
							}
						},
						{
							headerText: "메이커",
							dataField: "month_maker_name",
							width: "60",
							minWidth: "50",
						},
						{
							headerText: "대수",
							dataField: "month_machine_cnt",
							width: "60",
							minWidth: "50",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : $M.setComma(value);
							}
						},
						{
							headerText: "MS%",
							dataField: "month_ms_ratio",
							width: "60",
							minWidth: "50",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : $M.setComma(value) + "%";
							}
						}
					]
				},
				{
					headerText: "과 1년",
					dataField: "and1Year",
					headerStyle: "aui-center my-column-style",
					children: [
						{
							headerText: "전체",
							dataField: "year_total_cnt",
							width: "60",
							minWidth: "50",
							cellMerge: true,
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : $M.setComma(value);
							}
						},
						{
							headerText: "메이커",
							dataField: "year_maker_name",
							width: "60",
							minWidth: "50",
						},
						{
							headerText: "대수",
							dataField: "year_machine_cnt",
							width: "60",
							minWidth: "50",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : $M.setComma(value);
							}
						},
						{
							headerText: "MS%",
							headerStyle: "my-column-style",
							dataField: "year_ms_ratio",
							width: "60",
							minWidth: "50",
							style: "aui-center my-column-style",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : $M.setComma(value) + "%";
							}
						}
					]
				},
				{
					headerText: "구분",
					dataField: "cust_sale_type_name",
					width: "70",
					minWidth: "60"
				},
				{
					headerText: "상호",
					dataField: "breg_name",
					width: "100",
				},
				{
					headerText: "위탁판매점의 마케팅 활동 실적 집계",
					children: [
						{
							headerText: "과1년<br>계약합계",
							dataField: "tot_year_cnt",
							width: "100",
							minWidth: "100",
							cellMerge: true,
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : $M.setComma(value);
							}
						},
						{
							headerText: "과 3개월<br>계약대수",
							dataField: "thr_mon_cnt",
							width: "100",
							minWidth: "100",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : $M.setComma(value);
							}
						},
						{
							headerText: "과 1년<br>판매대수",
							dataField: "year_mon_cnt",
							width: "100",
							minWidth: "100",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : $M.setComma(value);
							}
						},
						{
							headerText: "렌탈장비출고대수",
							children: [
								{
									headerText: "메이커",
									dataField: "maker_name",
									width: "60",
									minWidth: "50"
								},
								{
									headerText: "대수",
									dataField: "rent_cnt",
									width: "60",
									minWidth: "50",
									labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
										return value == 0 || value == null ? "" : $M.setComma(value);
									}
								}
							]
						},
						{
							headerText: "누적계약<br>대수",
							dataField: "contract_cnt",
							width: "60",
							minWidth: "50",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : $M.setComma(value);
							}
						}
					]
				},
				// {
				// 	headerText: "YK 영업 네트워크 - 기초정보",
				// 	dataField: "group",
				// 	children: [
				// 		{
				// 			headerText: "위탁판매점수",
				// 			dataField: "agency_tot_cnt",
				// 			width: "60",
				// 			minWidth: "50",
				// 			cellMerge: true,
				// 			mergeRef: "org_name", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
				// 			mergePolicy: "restrict",
				// 			labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
				// 				// return value == 0 || value == null ? "" : $M.setComma(value);
				// 				return value == "" || value == null ? 0 : $M.setComma(value);
				// 			}
				// 		},
				// 		{
				// 			headerText: "합계",
				// 			dataField: "agency_cnt",
				// 			width: "40",
				// 			minWidth: "30",
				// 			labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
				// 				return value == 0 || value == null ? "" : $M.setComma(value);
				// 			}
				// 		},
				// 		{
				// 			headerText: "계약일자",
				// 			dataField: "sale_contract_dt",
				// 			width: "80",
				// 			minWidth: "70",
				// 			dataType: "date",
				// 			formatString: "yy-mm-dd"
				// 		},
				// 		{
				// 			headerText: "대표",
				// 			dataField: "breg_rep_name",
				// 			width: "80",
				// 			minWidth: "70"
				// 		},
				// 		{
				// 			headerText: "핸드폰",
				// 			dataField: "hp_no",
				// 			width: "60",
				// 			minWidth: "50"
				// 		},
				// 		{
				// 			headerText: "영업직원",
				// 			dataField: "sale_mem_name",
				// 			width: "60",
				// 			minWidth: "50"
				// 		},
				// 		{
				// 			headerText: "사무실",
				// 			dataField: "office",
				// 			width: "60",
				// 			minWidth: "50"
				// 		},
				// 		{
				// 			headerText: "팩스",
				// 			dataField: "fax_no",
				// 			width: "60",
				// 			minWidth: "50"
				// 		},
				// 		{
				// 			headerText: "주소",
				// 			dataField: "biz_addr",
				// 			width: "100",
				// 			minWidth: "90",
				// 			style: "aui-left"
				// 		},
				// 		{
				// 			headerText: "영업<br>능력",
				// 			dataField: "sale_ability_hmb",
				// 			width: "40",
				// 			minWidth: "30"
				// 		}
				// 	]
				// }
			];

			auiGridHalf = AUIGrid.create("#auiGridHalf", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridHalf, []);
		}

        // 전체정보 그리드 생성
        function createAUIGridFull() {

            var gridPros = {
                // rowIdField 설정
                rowIdField: "_$uid",
                showRowNumColumn: false,
                enableCellMerge: true, // 셀병합 사용여부
                rowStyleFunction: function (rowIndex, item) {
                    if (item.org_name != "센터" && item.area_do == "전체합계") {
                        return "aui-as-center-row-style";
                    } else if (item.org_name == "센터" && item.area_do == "전체합계") {
                        return "aui-as-tot-row-style";
                    }
                    return "";
                },
                // [15324] 틀 고정
                fixedColumnCount : 3
            };

            var columnLayout = [
                {
                    headerText: "센터",
                    dataField: "org_name",
                    width: "70",
                    minWidth: "60",
                    cellColMerge: true, // 셀 가로 병합 실행
                    cellColSpan: 3, // 셀 가로 병합 대상은 3개로 설정
                    cellMerge: true,
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        if (item.area_do == "전체합계") {
                            return "[" + value + "]";
                        }
                        return value;
                    }
                },
                {
                    headerText: "권역",
                    dataField: "area_do",
                    width: "60",
                    minWidth: "50",
                    cellMerge: true, // 구분1 셀 세로 병합 실행
                    mergeRef: "org_name", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
                    mergePolicy: "restrict"
                },
                {
                    headerText: "시/군",
                    dataField: "area_si",
                    width: "60",
                    minWidth: "50",
                    cellMerge: true, // 구분1 셀 세로 병합 실행
                    mergeRef: "org_name", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
                    mergePolicy: "restrict"
                },
                {
                    headerText: "서비스<br>고객수",
                    dataField: "tot_cust_cnt",
                    width: "60",
                    minWidth: "50",
                    cellMerge: true,
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        return value == 0 || value == null ? "" : $M.setComma(value);
                    }
                },
                {
                    headerText: "과 3개월",
                    dataField: "and3Mon",
                    children: [
                        {
                            headerText: "전체",
                            dataField: "month_total_cnt",
                            width: "60",
                            minWidth: "50",
                            cellMerge: true,
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return value == 0 || value == null ? "" : $M.setComma(value);
                            }
                        },
                        {
                            headerText: "메이커",
                            dataField: "month_maker_name",
                            width: "60",
                            minWidth: "50",
                        },
                        {
                            headerText: "대수",
                            dataField: "month_machine_cnt",
                            width: "60",
                            minWidth: "50",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return value == 0 || value == null ? "" : $M.setComma(value);
                            }
                        },
                        {
                            headerText: "MS%",
                            dataField: "month_ms_ratio",
                            width: "60",
                            minWidth: "50",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return value == 0 || value == null ? "" : $M.setComma(value) + "%";
                            }
                        }
                    ]
                },
                {
                    headerText: "과 1년",
                    headerStyle: "aui-center my-column-style",
                    dataField: "and1Year",
                    children: [
                        {
                            headerText: "전체",
                            dataField: "year_total_cnt",
                            width: "60",
                            minWidth: "50",
                            cellMerge: true,
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return value == 0 || value == null ? "" : $M.setComma(value);
                            }
                        },
                        {
                            headerText: "메이커",
                            dataField: "year_maker_name",
                            width: "60",
                            minWidth: "50",
                        },
                        {
                            headerText: "대수",
                            dataField: "year_machine_cnt",
                            width: "60",
                            minWidth: "50",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return value == 0 || value == null ? "" : $M.setComma(value);
                            }
                        },
                        {
                            headerText: "MS%",
                            headerStyle: "my-column-style",
                            dataField: "year_ms_ratio",
                            width: "60",
                            minWidth: "50",
                            style: "aui-center my-column-style",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return value == 0 || value == null ? "" : $M.setComma(value) + "%";
                            }
                        }
                    ]
                },
                {
                    headerText: "구분",
                    dataField: "cust_sale_type_name",
                    width: "70",
                    minWidth: "60"
                },
                {
                    headerText: "상호",
                    dataField: "breg_name",
                    width: "100",
                },
                {
                    headerText: "위탁판매점의 마케팅 활동 실적 집계",
                    children: [
                        {
                            headerText: "과1년<br>계약합계",
                            dataField: "tot_year_cnt",
                            width: "100",
                            minWidth: "100",
                            cellMerge: true,
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return value == 0 || value == null ? "" : $M.setComma(value);
                            }
                        },
                        {
                            headerText: "과 3개월<br>계약대수",
                            dataField: "thr_mon_cnt",
                            width: "100",
                            minWidth: "100",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return value == 0 || value == null ? "" : $M.setComma(value);
                            }
                        },
                        {
                            headerText: "과 1년<br>판매대수",
                            dataField: "year_mon_cnt",
                            width: "100",
                            minWidth: "100",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return value == 0 || value == null ? "" : $M.setComma(value);
                            }
                        },
                        {
                            headerText: "렌탈장비출고대수",
                            children: [
                                {
                                    headerText: "메이커",
                                    dataField: "maker_name",
                                    width: "60",
                                    minWidth: "50"
                                },
                                {
                                    headerText: "대수",
                                    dataField: "rent_cnt",
                                    width: "60",
                                    minWidth: "50",
                                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                        return value == 0 || value == null ? "" : $M.setComma(value);
                                    }
                                }
                            ]
                        },
                        {
                            headerText: "누적계약<br>대수",
                            dataField: "contract_cnt",
                            width: "60",
                            minWidth: "50",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return value == 0 || value == null ? "" : $M.setComma(value);
                            }
                        }
                    ]
                },
                {
                    headerText: "YK 마케팅 네트워크 - 기초정보",
                    dataField: "group",
                    children: [
                        {
                            headerText: "위탁판매점수",
                            dataField: "cnt",
                            width: "60",
                            minWidth: "50",
                            cellMerge: true,
                            mergeRef: "org_name", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
                            mergePolicy: "restrict",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                // return value == 0 || value == null ? "" : $M.setComma(value);
                                return value == "" || value == null ? 0 : $M.setComma(value);
                            }
                        },
                        // {
                        //     headerText: "합계",
                        //     dataField: "agency_cnt",
                        //     width: "40",
                        //     minWidth: "30",
                        //     labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        //         return value == 0 || value == null ? "" : $M.setComma(value);
                        //     }
                        // },
                        {
                            headerText: "계약일자",
                            dataField: "sale_contract_dt",
                            width: "80",
                            minWidth: "70",
                            dataType: "date",
                            formatString: "yy-mm-dd"
                        },
                        {
                            headerText: "대표",
                            dataField: "breg_rep_name",
                            width: "80",
                            minWidth: "70"
                        },
                        {
                            headerText: "핸드폰",
                            dataField: "hp_no",
                            width: "115",
                            minWidth: "110"
                        },
                        {
                            // [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
                            // headerText: "대리점<br>관리자",
                            headerText: "위탁판매점<br>관리자",
                            dataField: "sale_mem_name",
                            width: "100",
                            minWidth: "50"
                        },
                        {
                            headerText: "TEL",
                            dataField: "tel_no",
                            width: "115",
                            minWidth: "110"
                        },
                        {
                            headerText: "팩스",
                            dataField: "fax_no",
                            width: "115",
                            minWidth: "110"
                        },
                        {
                            headerText: "주소",
                            dataField: "office",
                            width: "240",
                            minWidth: "90",
                            style: "aui-left"
                        },
                        {
                            headerText: "마케팅<br>능력",
                            dataField: "sale_ability_hmb",
                            width: "40",
                            minWidth: "30"
                        }
                    ]
                }
            ];

			auiGridFull = AUIGrid.create("#auiGridFull", columnLayout, gridPros);
            AUIGrid.setGridData(auiGridFull, []);

            $("#auiGridFull").hide();
        }

        // 펼침
        function fnChangeColumn() {
        	$("#s_network_detail_yn").change(function (){
				if($("#s_network_detail_yn").is(":checked")){ // 그리드 스위칭
					$("#auiGridHalf").hide();
					$("#auiGridFull").show();
				}else{
					$("#auiGridHalf").show();
					$("#auiGridFull").hide();
				}
			});
        }
    </script>
</head>
<body>
<form id="main_form" name="main_form">
    <div class="layout-box">
        <!-- contents 전체 영역 -->
        <div class="content-wrap">
            <div class="content-box">
                <!-- 메인 타이틀 -->
                <div class="main-title">
                    <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
                </div>
                <!-- /메인 타이틀 -->
                <div class="contents">
                    <!-- 기본 -->
                    <div class="search-wrap">
                        <table class="table">
                            <colgroup>
                                <col width="60px">
                                <col width="140px">
                                <col width="30px">
                                <col width="80px">
                                <col width="">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>조회년월</th>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="col-auto">
                                            <jsp:include page="/WEB-INF/jsp/common/yearSelect.jsp">
                                                <jsp:param name="sort_type" value="d"/>
                                                <jsp:param name="year_name" value="s_year"/>
                                                <jsp:param name="min_year" value="2010"/>
                                            </jsp:include>
                                        </div>
                                        <div class="col-auto">
                                            <select class="form-control" id="s_mon" name="s_mon">
                                                <c:forEach var="i" begin="1" end="12" step="1">
                                                    <option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>"
                                                            <c:if test="${i eq inputParam.s_mon}">selected</c:if>>${i}월
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </div>
                                </td>
                                <th>센터</th>
                                <td>
                                    <select class="form-control" name="s_org_code" id="s_org_code">
                                        <option value="">- 전체 -</option>
                                        <c:forEach items="${warehouseList}" var="item">
												<option value="${item.center_org_code}" <c:if test="${item.center_org_code == inputParam.s_center_org_code}">selected="selected"</c:if> >${item.center_org_name}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <td class="">
                                    <button type="button" class="btn btn-important" style="width: 50px;"
                                            onclick="javascript:goSearch();">조회
                                    </button>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- /기본 -->
                    <!-- 그리드 타이틀, 컨트롤 영역 -->
                    <div class="title-wrap mt10">
                        <h4>조회결과</h4>
                        <div class="btn-group">
                            <div class="right">
                                <label for="s_detail_yn" style="color:black;">
                                    <input type="checkbox" id="s_detail_yn" name="s_detail_yn" checked="checked"
                                           value="Y"><span>권역포함 상세보기</span>
                                </label>
                                <label for="s_network_detail_yn" style="color:black;">
                                    <input type="checkbox" id="s_network_detail_yn" name="s_network_detail_yn"
                                           onclick="javascript:fnChangeColumn();"><span>위탁판매점 기초정보 상세보기</span>
                                            <%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
                                           <%--onclick="javascript:fnChangeColumn();"><span>대리점기초정보 상세보기</span>--%>
                                </label>
                                <c:if test="${page.add.POS_UNMASKING eq 'Y'}">
                                    <input type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
                                    <label for="s_masking_yn" >마스킹 적용</label>
                                </c:if>
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                                    <jsp:param name="pos" value="TOP_R"/>
                                </jsp:include>
                            </div>
                        </div>
                    </div>
					<!-- 기초정보를 제외한 그리드 -->
					<div id="auiGridHalf" style="height: 555px; width: 100%"></div>
					<!-- /기초정보를 제외한 그리드 -->
					<!-- 모든정보를 가진 그리드 -->
					<div id="auiGridFull" style="height: 555px; width: 100%"></div>
					<!-- /모든정보를 가진 그리드 -->
                </div>
            </div>
            <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
        </div>
        <!-- /contents 전체 영역 -->
    </div>
</form>
</body>
</html>
