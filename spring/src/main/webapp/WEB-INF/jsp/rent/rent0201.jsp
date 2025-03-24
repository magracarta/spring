<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈대장 > 렌탈장비대장 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>

	<script type="text/javascript">
		var auiGrid;
		var opTimeWidth = "70"; // 가동시간 width
		let foldList = []; // 펼침 & 접힘 항목 (그리드 생성 시 insert)

		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();

			// 렌탈장비운영현황 > 분포현황에서 열린 팝업일 경우
			if ('${inputParam.parent_page}' != '') {
				const param = {
					"s_body_no_arr" : "${searchList}",
					"s_sale_include_yn" : "${include_sold_yn}"
				};
				changeColumnToSaleInclude();
				fnSearch(param);
				document.getElementById("s_sale_include_yn").checked = "${include_sold_yn}" == "Y" ? true : false;
			} else {
				// 2024-04-23 (22501) 황빛찬 : 해당메뉴 조회 시간이 오래걸려 임시로 페이지 진입시 조회 하지 않도록 조치
				// 임시로 검색조건 셋팅 후 조회함.
				// goSearch('Y');
				goSearch();
			}

			// 펼침 컬럼 목록 생성
			AUIGrid.getColumnInfoList(auiGrid).forEach(map => {
				if (map.headerStyle && map.headerStyle === "aui-fold") {
					foldList.push(map.dataField);
				}
			});
			// 기본값 접힘
			AUIGrid.hideColumnByDataField(auiGrid, foldList);

		});

		// 칼럼 레이아웃 변경
		function changeColumnToSaleInclude() {

			//AUIGrid 칼럼 레이아웃 설정
			var columnLayout = [
				{
					headerText : "관리센터",
					dataField : "mng_org_name",
					width : "55",
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "소유센터",
					dataField : "own_org_name",
					width : "55",
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "메이커",
					dataField : "maker_name",
					width : "55",
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "모델명",
					dataField : "machine_name",
					width : "100",
					minWidth : "100",
					style : "aui-left",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "차대번호",
					dataField : "body_no",
					width : "150",
					minWidth : "120",
					style : "aui-center aui-popup",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "엔진번호",
					headerStyle : "aui-fold",
					dataField : "engine_no_1",
					width : "150",
					minWidth : "120",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "연식",
					width : "55",
					minWidth : "45",
					dataField : "made_dt",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value.substr(0, 4);
					},
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "가동시간",
					dataField : "op_hour",
					width : opTimeWidth,
					minWidth : "45",
					style : "aui-center",
					dataType : "numeric",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "매입일자",
					dataField : "buy_dt",
					dataType : "date",
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					width : "70",
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "매입종류",
					headerStyle : "aui-fold",
					dataField : "buy_type_name",
					width : "60",
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "판매가격",
					dataField : "buy_price",
					width : "100",
					minWidth : "45",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "GPS",
					dataField : "gps_no",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var ret = value;
						if (item.sar != null && item.sar != "") {
							ret = "SA-R";
						}
						return ret;
					},
					width : "100",
					minWidth : "100",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "번호판종류",
					headerStyle : "aui-fold",
					dataField : "mreg_no_type_name",
					width : "90",
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "번호판번호",
					dataField : "mreg_no",
					width : "90",
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "매각고려장비",
					dataField : "mch_sale_yn",
					width : "100",
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "판매일자",
					dataField : "sale_dt",
					dataType : "date",
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					width : "80",
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "판매가격",
					dataField : "sale_price",
					width : "70",
					minWidth : "45",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "판매수익",
					dataField : "sale_profit_amt",
					width : "70",
					minWidth : "45",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "감가종료일",
					headerStyle : "aui-fold",
					dataField : "reduce_ed_dt",
					dataType : "date",
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					width : "90",
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				// {
				// 	headerText : "최소판가",
				// 	headerStyle : "aui-fold",
				// 	dataField : "min_sale_price",
				// 	width : "90",
				// 	minWidth : "45",
				// 	style : "aui-right",
				// 	dataType : "numeric",
				// 	formatString : "#,##0",
				// 	filter : {
				// 		showIcon : true
				// 	}
				// },
				{
					headerText : "장비상세",
					dataField : "remark",
					minWidth : "100",
					style : "aui-left",
				},
				{
					dataField : "rental_machine_no",
					visible : false
				},
				{
					dataField : "sar",
					visible : false
				}
			];

			// 칼럼 레이아웃 변경
			AUIGrid.changeColumnLayout(auiGrid, columnLayout);
		};


		//칼럼 레이아웃 변경
		function changeColumnToSaleExclude() {

			//AUIGrid 칼럼 레이아웃 설정
			var columnLayout = [
				{
					headerText : "관리센터",
					dataField : "mng_org_name",
					width : "80",
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "소유센터",
					dataField : "own_org_name",
					width : "80",
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "메이커",
					dataField : "maker_name",
					width : "55",
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "모델명",
					dataField : "machine_name",
					width : "100",
					minWidth : "45",
					style : "aui-left",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "차대번호",
					dataField : "body_no",
					width : "150",
					minWidth : "100",
					style : "aui-center aui-popup",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "엔진번호",
					headerStyle : "aui-fold",
					dataField : "engine_no_1",
					width : "150",
					minWidth : "100",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "연식",
					width : "55",
					minWidth : "45",
					dataField : "made_dt",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value.substr(0, 4);
					},
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "가동시간",
					dataField : "op_hour",
					width : opTimeWidth,
					minWidth : "45",
					style : "aui-center",
					dataType : "numeric",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "매입일자",
					dataField : "buy_dt",
					dataType : "date",
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					width : "70",
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "매입종류",
					headerStyle : "aui-fold",
					dataField : "buy_type_name",
					width : "60",
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "판매가격",
					dataField : "buy_price",
					width : "90",
					minWidth : "45",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "GPS",
					dataField : "gps_no",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var ret = value;
						if (item.sar != null && item.sar != "") {
							ret = "SA-R";
						}
						return ret;
					},
					width : "100",
					minWidth : "100",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "번호판종류",
					headerStyle : "aui-fold",
					dataField : "mreg_no_type_name",
					width : "90",
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "번호판번호",
					dataField : "mreg_no",
					width : "90",
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "매각고려장비",
					dataField : "mch_sale_yn",
					width : "100",
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "감가종료일",
					headerStyle : "aui-fold",
					dataField : "reduce_ed_dt",
					dataType : "date",
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					width : "90",
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				// {
				// 	headerText : "최소판가",
				// 	headerStyle : "aui-fold",
				// 	dataField : "min_sale_price",
				// 	width : "70",
				// 	minWidth : "45",
				// 	style : "aui-right",
				// 	dataType : "numeric",
				// 	formatString : "#,##0",
				// 	filter : {
				// 		showIcon : true
				// 	}
				// },
				{
					headerText : "장비상세",
					dataField : "remark",
					// width : "110",
					minWidth : "100",
					style : "aui-left",
				},
				{
					dataField : "rental_machine_no",
					visible : false
				},
				{
					dataField : "sar",
					visible : false
				}
			];

			// 칼럼 레이아웃 변경
			AUIGrid.changeColumnLayout(auiGrid, columnLayout);

		};

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				showRowNumColumn: true,
				enableFilter :true,
			};

			auiGrid = AUIGrid.create("#auiGrid", [], gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			// 상세팝업
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				//차대번호셀 선택한 경우
				if(event.dataField == "body_no" ) {
					var params = {rental_machine_no : event.item.rental_machine_no};
					var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=500, left=0, top=0";
					$M.goNextPage('/rent/rent0201p01', $M.toGetParam(params), {popupStatus : popupOption});
				}

			});

			// 센터일 경우 본인 센터 조회된 상태로 시작(2020-11-10), 다른센터것도 조회할수있지만, 신청은 불가
			<c:if test="${page.fnc.F00949_001 eq 'Y'}">
				goSearch();
			</c:if>
		}

		// 조회
		function goSearch() {
			var param = {
				"s_start_buy_dt" : $M.getValue("s_start_buy_dt")
				, "s_end_buy_dt" : $M.getValue("s_end_buy_dt")
				, "s_maker_cd" : $M.getValue("s_maker_cd")
				, "s_machine_plant_seq" : $M.getValue("s_machine_plant_seq")
				, "s_machine_name" : $M.getValue("s_machine_name")
				, "s_body_no" : $M.getValue("s_body_no")
				, "s_buy_type_un" : $M.getValue("s_buy_type_un")
				, "s_made_dt" : $M.getValue("s_made_dt")
				, "s_sale_include_yn" : $M.getValue("s_sale_include_yn") == "Y" ? "Y" : "N"
				, "s_mch_sale_yn" : $M.getValue("s_mch_sale_yn") == "Y" ? "Y" : "N"
				, "s_mng_org_code" : $M.getValue("s_mng_org_code")
				, "s_own_org_code" : $M.getValue("s_own_org_code")
			};
			_fnAddSearchDt(param, 's_start_buy_dt', 's_end_buy_dt');
			if ($M.getValue("s_sale_include_yn") == "Y") {
				changeColumnToSaleInclude();
			} else {
				changeColumnToSaleExclude();
			}
			fnChangeColumn();
			// 2024-04-23 (22501) 황빛찬 : 해당메뉴 조회 시간이 오래걸려 임시로 페이지 진입시 조회 하지 않도록 조치
			// 임시로 검색조건 셋팅 후 조회함.
			// if (flag != 'Y') {
			// 	fnSearch(param);
			// }
            fnSearch(param);
		}

		function fnSearch(param) {
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
			);
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			var exportProps = {};
			fnExportExcel(auiGrid, "렌탈장비대장", exportProps);
	    }

		// 페이지 이동
		function goNew() {
 			$M.goNextPage("/rent/rent020101");
		}

		// 엔터
		function enter(fieldObj) {
	       var field = ["s_body_no", "s_machine_name"];
	       $.each(field, function() {
	          if (fieldObj.name == this) {
	             goSearch(document.main_form);
	          }
	       });
	    }

		// 펼침
		function fnChangeColumn() {
			const target = document.getElementById('s_toggle_column').checked;
			if (target) {
				AUIGrid.showColumnByDataField(auiGrid, foldList);
			} else {
				AUIGrid.hideColumnByDataField(auiGrid, foldList);
			}
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
								<col width="260px">
								<col width="55px">
								<col width="80px">
								<col width="55px">
								<col width="130px">
								<col width="60px">
								<col width="70px">
								<col width="55px">
								<col width="70px">
								<col width="35px">
								<col width="70px">
								<col width="60px">
								<col width="80px">
								<col width="60px">
								<col width="80px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>매입일자</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col-5">
												<div class="input-group" style="flex-wrap: nowrap;">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_buy_dt" name="s_start_buy_dt" dateformat="yyyy-MM-dd" alt="요청시작일" value="${searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto text-center">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_buy_dt" name="s_end_buy_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${searchDtMap.s_end_dt}">
												</div>
											</div>
											<div style="padding-left: 5px">
												<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
						                     		<jsp:param name="st_field_name" value="s_start_buy_dt"/>
						                     		<jsp:param name="ed_field_name" value="s_end_buy_dt"/>
						                     		<jsp:param name="click_exec_yn" value="Y"/>
						                     		<jsp:param name="exec_func_name" value="goSearch();"/>
						                     	</jsp:include>
					                     	</div>
										</div>
									</td>
									<th>메이커</th>
									<td>
										<select class="form-control" id="s_maker_cd" name="s_maker_cd">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['MAKER']}" var="item">
												<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
													<option value="${item.code_value}" <c:if test="${result.maker_cd == item.code_value}">selected</c:if>>${item.code_name}</option>
												</c:if>
											</c:forEach>
										</select>
									</td>
									<th>모델명</th>
									<td>
										<input type="text" class="form-control" id="s_machine_name" name="s_machine_name">
									</td>
									<th>차대번호</th>
									<td>
										<input type="text" class="form-control" id="s_body_no" name="s_body_no">
									</td>
									<th>매입종류</th>
									<td>
										<select class="form-control" id="s_buy_type_un" name="s_buy_type_un">
											<option value="">- 전체 -</option>
											<option value="U">중고</option>
											<option value="N">신차</option>
										</select>
									</td>
									<th>연식</th>
									<td>
										<select class="form-control" id="s_made_dt" name="s_made_dt">
											<option value="">- 전체 -</option>
											<option value="2">2년이하</option>
											<option value="3~4">3~4년식</option>
											<option value="5~6">5~6년식</option>
											<option value="7">7년 이상</option>
										</select>
									</td>
									<th>관리센터</th>
									<td>
										<select class="form-control" id="s_mng_org_code" name="s_mng_org_code">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${orgCenterList}">
												<option value="${item.org_code}"
												<c:if test="${SecureUser.org_type eq 'CENTER' && SecureUser.org_code eq item.org_code}">selected</c:if>
												>${item.org_name}</option>
											</c:forEach>
											<option value="5010">서비스운영</option>
										</select>
									</td>
									<th>소유센터</th>
									<td>
										<select class="form-control" id="s_own_org_code" name="s_own_org_code">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${orgCenterList}">
												<option value="${item.org_code}">${item.org_name}</option>
											</c:forEach>
											<option value="5010">서비스운영</option>
										</select>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;"   onclick="javascript:goSearch()"   >조회</button>
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
						<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
<!-- 							<button type="button" class="btn btn-default"  onclick="javascript:fnExportExcel();"  ><i class="icon-btn-excel inline-btn" ></i>엑셀다운로드</button> -->
							<div class="form-check form-check-inline pl5">
								<label><input class="form-check-input" style="margin: 2px .3125rem 1px 0" type="checkbox" id="s_mch_sale_yn" name="s_mch_sale_yn" value="Y" onclick="javascript:goSearch()">매각고려장비</label>
								<label><input class="form-check-input" style="margin: 2px .3125rem 1px 0" type="checkbox" id="s_sale_include_yn" name="s_sale_include_yn" value="Y" onclick="javascript:goSearch()">판매포함</label>
								<label for="s_toggle_column">
									<input type="checkbox" id="s_toggle_column" style="margin: 2px .3125rem 1px 5px;" onclick="fnChangeColumn()">펼침
								</label>
							</div>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->
				<div  id="auiGrid"  style="margin-top: 5px; height: 555px;"></div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>
					<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
						<!-- 팝업으로 호출된 경우 버튼 숨김 -->
						<c:if test="${empty inputParam.parent_page}">
<%--							<button type="button" class="btn btn-info"  onclick="javascript:goNew();"  >렌탈장비 신규등록</button>--%>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</c:if>
					</div>
				</div>
	<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>
		</div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
<!-- /contents 전체 영역 -->
</div>
</form>
</body>
</html>
