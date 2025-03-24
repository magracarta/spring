 <%@ page contentType="text/html;charset=utf-8" language="java" %> <%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %> <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %> <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> <%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %> <%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > MS관리 > MS관리-지역별 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-08-20 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var auiGridArea; // 영업지역 Grid
		var auiGrid;
		var dateList;
		var dataFieldName = []; // 펼침 항목(create할때 넣음)

        $(document).ready(function () {
        	fnInit();
            createAUIGridArea();
            createAUIGrid();
			goSearch();
        });

		// 계약추이분석
		function goTransitionPopup() {
			var params = {
				s_search_year : $M.getValue("s_end_year")
			};
			var popupOption = 'scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=531, left=0, top=0';
			$M.goNextPage('/sale/sale0501p03', $M.toGetParam(params), {popupStatus : popupOption});
		}

		function goAmtGraphPopup() {
			goGraphPopup('amt');
		}

		function goRatioGraphPopup() {
			goGraphPopup('ratio');
		}

		// 수량그래프, 비율그래프 팝업
		function goGraphPopup(type) {
			// validation check
			if($M.getValue("s_maker_cd") == "") {
				alert("메이커는 최소 1개 이상 선택해야 합니다.");
				return;
			}

			var sMakerCd = $M.getValue("s_maker_cd").split("#");
			var makerCdArr = [];
			for(var i=0; i<sMakerCd.length; i++) {
				if(makerCdArr.indexOf(sMakerCd[i]) === -1) {
					makerCdArr.push(sMakerCd[i]);
				}
			}

			if(makerCdArr.length > 9) {
				alert("메이커는 최대 9개까지 선택 가능합니다.\n현재 " + makerCdArr.length + "개 선택하셨습니다.");
				return;
			}

			// 체크된 지역
			var areaGridData = AUIGrid.getCheckedRowItemsAll(auiGridArea);
			console.log(areaGridData);
			if(areaGridData.length <= 0) {
				alert("마케팅지역을 1곳 이상 선택해주세요.");
				return;
			}

			// 체크된 순서가 아니라 그리드에 표기된 순서여야 차트에 해당지역 가져올수있어서 정렬함!
			areaGridData.sort($M.sortMulti("full_sort_no"));

			var area_name_array = [];
			var area_sale_code_str = [];
			var area_sale_name = [];
			console.log(areaGridData);
			for (var i = 0; i < areaGridData.length; ++i) {
				try {
					area_sale_code_str.push(areaGridData[i].sale_area_code);
					if (areaGridData[i].up_sale_area_code == "000") {
						area_sale_name.push(areaGridData[i].sale_area_name);
					}
					// 차트 해당지역, 권역별 전체는 "강원권전체" 형태로 표시, 개별체크는 선택된 지역명 모두 출력
					console.log(areaGridData[i].up_sale_area_code, areaGridData[i].sale_area_name, area_sale_code_str.indexOf(areaGridData[i].up_sale_area_code));
					if (area_sale_code_str.indexOf(areaGridData[i].up_sale_area_code) == -1) {
						var name = areaGridData[i].sale_area_name;
						if (areaGridData[i]._$leafCount != 0) {
							name = name + "전체";
						}
						area_name_array.push(name);
					}
				} catch (e) {
					console.log(e);
					console.log(areaGridData[i]);
				}
			}

			console.log(area_name_array);

			var startDt = fnSetDate($M.getValue("s_start_year"), $M.getValue("s_start_mon"));
			var endDt = fnSetDate($M.getValue("s_end_year"), $M.getValue("s_end_mon"));

			var params = {
				"type" : type,
				"s_start_dt" : startDt,
				"s_end_dt" : endDt,
				"area_name" : area_name_array.join(', '),
				"s_ms_machine_type_cd" : $M.getValue("s_ms_machine_type_cd"),
				"s_maker_cd_str" : $M.getArrStr(makerCdArr),
				"s_area_sale_code_str" : $M.getArrStr(area_sale_code_str)
			};
			console.log(params);

			var popupOption = 'scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=531, left=0, top=0';
			$M.goNextPage('/sale/sale0501p02', $M.toGetParam(params), {popupStatus : popupOption});
		}

        function fnInit() {
			dateList = ${dateList};
			var msMakerCd = "${defaultMakerCd}";
			var msMakerCdArr = msMakerCd.split("#");

			$('#s_maker_cd').combogrid("setValues", msMakerCdArr);
		}

        function goSearch() {
			// validation check
			if($M.getValue("s_maker_cd") == "") {
				alert("메이커는 최소 1개 이상 선택해야 합니다.");
				return;
			}

			var sMakerCd = $M.getValue("s_maker_cd").split("#");
			var makerCdArr = [];
			for(var i=0; i<sMakerCd.length; i++) {
				if(makerCdArr.indexOf(sMakerCd[i]) === -1) {
					makerCdArr.push(sMakerCd[i]);
				}
			}

			if(makerCdArr.length > 9) {
				alert("메이커는 최대 9개까지 선택 가능합니다.\n현재 " + makerCdArr.length + "개 선택하셨습니다.");
				return;
			}

			// 체크된 지역
			var areaGridData = AUIGrid.getCheckedRowItems(auiGridArea);
			if(areaGridData.length <= 0) {
				alert("마케팅지역을 1곳 이상 선택해주세요.");
				return;
			}

			var area_sale_code_str = [];
			for (var i = 0; i < areaGridData.length; ++i) {
				area_sale_code_str.push(areaGridData[i].item.sale_area_code);
			}

			var startDt = fnSetDate($M.getValue("s_start_year"), $M.getValue("s_start_mon"));
			var endDt = fnSetDate($M.getValue("s_end_year"), $M.getValue("s_end_mon"));
			console.log(startDt);

			var params = {
				"s_start_dt" : startDt,
				"s_end_dt" : endDt,
				"s_ms_machine_type_cd" : $M.getValue("s_ms_machine_type_cd"),
				"s_maker_cd_str" : $M.getArrStr(makerCdArr),
				"s_area_sale_code_str" : $M.getArrStr(area_sale_code_str)
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: "GET"},
				function (result) {
					if (result.success) {
						destroyGrid();
						dateList = result.dateList;
						createAUIGrid();
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
			);
        }

		// 그리드 초기화
		function destroyGrid() {
			AUIGrid.destroy("#auiGrid");
			auiGrid = null;
			// 조회 후 "펼침" 버튼 초기화
			$("input:checkbox[id='s_toggle_column']").attr("checked", false);
		};

        function fnSetDate(year, mon) {
        	if(mon.length == 1) {
        		mon = "0" + mon;
			}
        	var sYearMon = year + mon;

        	return $M.dateFormat($M.toDate(sYearMon), 'yyyyMM');
		}

        function fnDownloadExcel() {
			fnExportExcel(auiGrid, "MS관리-지역별");
        }

        function createAUIGridArea() {
            var gridProsTree = {
                rowIdField: "sale_area_code",
                enableFilter: true,
                displayTreeOpen: false,
                showRowCheckColumn: true,
                rowCheckDependingTree: true,
                showRowNumColumn: false
            };

            var columnLayoutTree = [
                {
                    headerText: "마케팅지역",
                    dataField: "sale_area_name",
                    style: "aui-left",
                    editable: false,
                    filter: {
                        showIcon: true
                    }
                },
                {
                    headerText: "마케팅구역코드",
                    dataField: "sale_area_code",
                    visible: false
                }
            ];

            auiGridArea = AUIGrid.create("#auiGridArea", columnLayoutTree, gridProsTree);
            AUIGrid.setGridData(auiGridArea, ${list});
            $("#auiGridArea").resize();

            // 그리드 전체 체크
            AUIGrid.setAllCheckedRows(auiGridArea, true);
        }

        function createAUIGrid() {
			// 조회결과
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: false,
				displayTreeOpen : true,
				useGroupingPanel : false,
				showBranchOnGrouping : false,
				// fixedColumnCount : 6, // 고정칼럼 카운트 지정
				footerPosition: "top",
				showFooter: false,
				enableCellMerge : true,
				cellMergeRowSpan:  true,
				rowSelectionWithMerge : true,
				enableSummaryMerge : true,
				summaryMergePolicy : "all",
				// [23426] 총계 틀 고정
				fixedRowCount : 1,
				// 그리드 ROW 스타일 함수 정의
				rowStyleFunction : function(rowIndex, item) {
					if((item.ms_machine_sub_type_name.indexOf("소계") != -1 && item.ms_machine_sub_type_name.indexOf("[") == -1)
							|| (item.ms_machine_sub_type_name.indexOf("총계") != -1 && item.ms_machine_sub_type_name.indexOf("[") == -1)) {
						return "aui-grid-row-depth3-style";
					} else if(item.ms_machine_sub_type_name.indexOf("[") != -1) {
						return "aui-ms-col-style";
					}

					return null;
				},
				// [15324] 틀 고정
				fixedColumnCount : 2
			};

			var columnLayout = [
				{
					headerText : "규격",
					dataField : "ms_machine_sub_type_name",
					width : "120",
					minWidth : "25",
					cellMerge : true, // 셀 세로 병합 실행
// 					cellColMerge : true, // 셀 가로 병합 실행
// 					cellColSpan : 2, // 셀 가로 병합 대상은 2개로 설정
					style : "aui-center",
				},
				{
					headerText : "메이커",
					dataField : "maker_name",
					width : "80",
					minWidth : "25",
					style : "aui-center",
				},
				{
					headerText : "규격코드",
					dataField : "ms_machine_sub_type_cd",
					visible : false
				},
				{
					headerText : "메이커코드",
					dataField : "maker_cd",
					visible : false
				},
				{
					headerText: "기간내",
					children: [
						{
							headerText: "수량",
							dataField: "a_total_qty",
							width : "45",
							minWidth : "25",
							style: "aui-center",
							// [14512] 기간내 수량 클릭했을때도 [MS리스트] 팝업이 뜨도록 개선 - 작성자 김경빈
							styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if (item.ms_machine_sub_type_name.indexOf("총계") === -1) {
									if (item.ms_machine_sub_type_name.indexOf("소계 ]") !== -1) {
										return "aui-sub-total-popup";
									} else {
										return "aui-popup"; // AUI CSS - 팝업
									}
								}
								return null;
							},
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								return value == "0"? "" : $M.setComma(value);
							}
						},
						{
							dataField: "a_total_rate",
							headerText: "비율",
							postfix: "%",
							headerStyle : "aui-fold",
							width : "50",
							minWidth : "25",
							style: "aui-center",
							// [14512] 비율항목에 막대그래프 표시 - 작성자 김경빈
							renderer : {
								type : "BarRenderer",
								min : 0,
								max : 100
							},
						}
					]
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			for (var i = 0; i < dateList.length; ++i) {
				var result = dateList[i];
				var yearMon = String(result.year_mon).replace("-", "");
				var dataFiledName = "a_" + yearMon + "_qty";
				var rateFiledName = "a_" + yearMon + "_rate";
				var columnObj = {
					headerText : result.year_mon,
					children : [
						{
							headerText : "수량",
							dataField : dataFiledName,
							width : "7%",
							style : "aui-center",
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if (item.ms_machine_sub_type_name.indexOf("총계") === -1) {
									if (item.ms_machine_sub_type_name.indexOf("소계 ]") !== -1) {
										return "aui-sub-total-popup";
									} else {
										return "aui-popup";
									}
								}
								return null;
							},
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								return value == "0"? "" : $M.setComma(value);
							}
						},
						{
							headerText : "비율",
							dataField : rateFiledName,
							headerStyle : "aui-fold",
							postfix : "%",
							width : "7%",
							style : "aui-center",
							// [14512] 비율항목에 막대그래프 표시
							renderer : {
								type : "BarRenderer",
								min : 0,
								max : 100
							},
						}
					]
				};

				AUIGrid.addColumn(auiGrid, columnObj, 'last');
			}

			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellClick", function(event) {

				var makerCd = $M.getValue("s_maker_cd");
				var area_sale_code_str = [];
				var areaGridData = AUIGrid.getCheckedRowItems(auiGridArea);
				for (var i = 0; i < areaGridData.length; ++i) {
					area_sale_code_str.push(areaGridData[i].item.sale_area_code);
				}

				var msMon = event.dataField.split("_")[1];

				// 기간내 수량을 선택했을 때 시작날짜와 끝날짜를 붙임
				if (msMon === "total") {
					var startDt = fnSetDate($M.getValue("s_start_year"), $M.getValue("s_start_mon"));
					var endDt = fnSetDate($M.getValue("s_end_year"), $M.getValue("s_end_mon"));
					msMon += startDt + endDt;
				}

				var dataField = "a_" + msMon + "_qty";
				if (event.headerText == "수량" && event.item[dataField] != ""
						// && event.dataField != "a_total_qty" // 기간내 수량이 클릭되도록 변경
						// && (event.item.ms_machine_sub_type_name.indexOf("톤 소계") != -1 || event.item.ms_machine_sub_type_name.indexOf("휠 소계") != -1 || event.item.ms_machine_sub_type_name.indexOf("소계") == -1) // [메이커 소계] MS리스트 팝업 호출
						&& event.item.ms_machine_sub_type_name.indexOf("총계") == -1) {

					var subTypeCd = event.item.ms_machine_sub_type_cd;
					// 기종: 미니굴삭기 && ms_machine_sub_type_cd(규격): 0102, 0103, 0104인 경우 메이커별 미니소계
					if (subTypeCd.indexOf("소계 ]") !== -1) {
						subTypeCd = "0102#0103#0104";
					}

					// 보낼 데이터
					var params = {
						"s_menu_type" : "region",
						"s_sub_type_cd" : subTypeCd,
						"s_ms_mon" : msMon,
						"s_area_code_str" : $M.getArrStr(area_sale_code_str)
					};

					if(event.item.maker_cd == "46") {
						params.s_select_type = "etc";
						// 메이커 선택 리스트에 기타가 포함되어있다면 제외
						if (makerCd.includes("46")) {
							makerCd = makerCd.replaceAll("46", "");
						}
						params.s_maker_cd_str = makerCd;
					} else if(event.item.maker_cd.length < 4) {
						params.s_select_type = "detail";
						params.s_maker_cd_str = event.item.maker_cd;
					} else {
						params.s_select_type = "total";
						params.s_maker_cd_str = makerCd;
					}

					$M.goNextPage('/sale/sale0501p01', $M.toGetParam(params), {popupStatus : ""});
				}
			});

			// 펼치기 전에 접힐 컬럼 목록
			var auiColList = AUIGrid.getColumnInfoList(auiGrid);

			for (var i = 0; i <auiColList.length; ++i) {
				if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
					dataFieldName.push(auiColList[i].dataField);
				}
			}

			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];
				AUIGrid.hideColumnByDataField(auiGrid, dataField);
			}
		}

        // 기종에 따른 메이커 조회
        function goSearchMakerList() {
        	var param = {
        			s_ms_machine_type_cd : $M.getValue("s_ms_machine_type_cd")
        	}

			$M.goNextPageAjax(this_page + "/search/maker", $M.toGetParam(param), {method: "GET"},
				function (result) {
					if (result.success) {
						console.log("result : ", result);

						$("#s_maker_cd").combogrid({
							panelWidth: "300",
							idField: "code_value",
							textField : "code_name",
						});

						// 콤보그리드 다시 세팅
						$("#s_maker_cd").combogrid("grid").datagrid("loadData", result.makerList);

						var msMakerCd = result.defaultMakerCd;
						var msMakerCdArr = msMakerCd.split("#");

						$('#s_maker_cd').combogrid("setValues", msMakerCdArr);
					}
				}
			);
        }

		// 펼침
		function fnChangeColumn(event) {
			var data = AUIGrid.getGridData(auiGrid);
			var target = event.target || event.srcElement;
			if(!target)	return;

			var dataField = target.value;
			var checked = target.checked;

			console.log("dataFieldName : ", dataFieldName);

			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGrid, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGrid, dataField);
				}
			}

 		    // 구해진 칼럼 사이즈를 적용 시킴.
// 			var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
// 		    AUIGrid.setColumnSizeList(auiGrid, colSizeList);
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
				<div class="row">
					<!-- 좌측영역 -->
					<div class="col-2">
						<div id="auiGridArea" style="margin-top: 1px; height: 700px;"></div>
					</div>
					<!-- /좌측영역 -->
					<!-- 우측영역 -->
					<div class="col-10">
						<!-- 검색영역 -->
						<div class="search-wrap">
							<table class="table">
								<colgroup>
									<col width="70px">
									<col width="350px">
									<col width="45px">
									<col width="100px">
									<col width="55px">
									<col width="400px">
								</colgroup>
								<tbody>
								<tr>
									<th>조회년월</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-3">
												<select class="form-control" id="s_start_year" name="s_start_year">
													<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
														<option value="${i}" <c:if test="${i==inputParam.s_start_year}">selected</c:if>>${i}년</option>
													</c:forEach>
												</select>
											</div>
											<div class="col-2">
												<select class="form-control" id="s_start_mon" name="s_start_mon">
													<c:forEach var="i" begin="1" end="12" step="1">
														<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==inputParam.s_start_mon}">selected</c:if>>${i}월</option>
													</c:forEach>
												</select>
											</div>
											<div class="col-1 text-center">~</div>
											<div class="col-3">
												<select class="form-control" id="s_end_year" name="s_end_year">
													<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
														<option value="${i}" <c:if test="${i==inputParam.s_end_year}">selected</c:if>>${i}년</option>
													</c:forEach>
												</select>
											</div>
											<div class="col-2">
												<select class="form-control" id="s_end_mon" name="s_end_mon">
													<c:forEach var="i" begin="1" end="12" step="1">
														<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==inputParam.s_end_mon}">selected</c:if>>${i}월</option>
													</c:forEach>
												</select>
											</div>
										</div>
									</td>
									<th>기종</th>
									<td>
										<select class="form-control" id="s_ms_machine_type_cd" name="s_ms_machine_type_cd" onchange="goSearchMakerList()">
											<c:forEach items="${codeMap['MS_MACHINE_TYPE']}" var="item">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>메이커</th>
									<td>
										<input class="form-control" style="width: 99%;" type="text" id="s_maker_cd" name="s_maker_cd" easyui="combogrid"
											   easyuiname="makerList" panelwidth="300" idfield="code_value" textfield="code_name" multi="Y"/>
									</td>
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>
								</tr>
								</tbody>
							</table>
						</div>
						<!-- /검색영역 -->
						<!-- 그리드 타이틀, 컨트롤 영역 -->
						<div class="title-wrap mt10">
							<h4>조회결과</h4>
							<div class="btn-group">
								<div class="right">
									<label for="s_toggle_column" style="color:black;">
										<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
									</label>
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
								</div>
							</div>
						</div>
						<!-- /그리드 타이틀, 컨트롤 영역 -->
						<div id="auiGrid" style="margin-top: 5px; height: 620px;"></div>
					</div>
					<!-- /우측영역 -->
				</div>

			</div>

		</div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
	<!-- /contents 전체 영역 -->
</div>
</form>
</body>
</html>