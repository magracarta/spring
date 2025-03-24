<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈운영 > 렌탈장비 출고/회수현황 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	
		var auiGrid;
		var page = 1;
		var moreFlag = "N";
		var isLoading = false;
		var dataFieldName = []; // 펼침 항목(create할때 넣음)
		
		$(document).ready(function() {
			//fnInitDate(); // 검색안되서 안함
			// AUIGrid 생성
			createAUIGrid();
			goSearch();
		});
		
		/* function fnSetDtType() {
			if ($M.getValue("s_date_type") == "ALL") {
				// $("#dtSearch").css("display", "none");
				$M.setValue("s_start_dt", "");
				$M.setValue("s_end_dt", "");
			} else {
				//$("#dtSearch").css("display", "flex");
			}
		} */
		
		// 펼침
		function fnChangeColumn(event) {
			var data = AUIGrid.getGridData(auiGrid);
			var target = event.target || event.srcElement;
			if(!target)	return;

			var dataField = target.value;
			var checked = target.checked;
			
			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGrid, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGrid, dataField);
				}
			}
			
 		    // 구해진 칼럼 사이즈를 적용 시킴.
			var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
		    AUIGrid.setColumnSizeList(auiGrid, colSizeList);
		}
		
		// 조회
		function goSearch() { 
			// if($M.getValue("s_rental_status_cd") == '' && $M.getValue('s_mng_org_code') == '' && $M.getValue('s_own_org_code') == '') {
			// 	alert('[상태, 관리센터, 소유센터] 중 하나는 필수입니다.');
			// 	return;
			// }
			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";
			fnSearch(function(result){
				AUIGrid.setGridData(auiGrid, result.list);
				$("#total_cnt").html(result.total_cnt);
				$("#curr_cnt").html(result.list.length);
				if (result.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				};
			});
		}
		
		function fnSearch(successFunc) {
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {
				return;
			};
			isLoading = true;
			var param = {
				s_maker_cd : $M.getValue("s_maker_cd"),
				s_machine_plant_seq : $M.getValue("s_machine_plant_seq"),
				s_body_no : $M.getValue("s_body_no"),
				s_cust_name : $M.getValue("s_cust_name"),
				s_own_org_code : $M.getValue("s_own_org_code"),
				s_mng_org_code : $M.getValue("s_mng_org_code"),
				s_reg_year : $M.getValue("s_reg_year"),
				s_rental_status_cd : $M.getValue("s_rental_status_cd"),
				s_st_dt : $M.getValue("s_start_dt"),
				s_ed_dt : $M.getValue("s_end_dt"),
				s_sort_key : "vd.out_dt desc nulls first, doc_path",
				s_masking_yn : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
				s_sort_method : "asc",
				s_made_dt : $M.getValue("s_made_dt"),
				s_date_type : $M.getValue("s_date_type"),
				page : page,
				rows : $M.getValue("s_rows")
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			if (param.s_start_dt == "" && param.s_end_dt == "") {
				delete param['s_st_dt'];delete param['s_ed_dt'];
			}
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					/* if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					}; */
					isLoading = false;
					if(result.success) {
						successFunc(result);
					};
				}
			)
		}
		
		// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
		function fnScollChangeHandelr(event) {
			if(event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
				goMoreData();
			};
		}
		
		function goMoreData() {
			fnSearch(function(result){
				result.more_yn == "N" ? moreFlag = "N" : page++;  
				if (result.list.length > 0) {
					console.log(result.list);
					AUIGrid.appendData("#auiGrid", result.list);
					$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
				};
			});
		}
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				enableFilter :true,
				rowIdField : "rental_doc_no",
				rowIdTrustMode : true,
				showRowNumColumn: true
			};
			var columnLayout = [
				{
					headerText : "관리번호",
					dataField : "rental_doc_no",
					width : "60",
					minWidth : "60",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return value.substring(4);
					},
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "관리센터", 
					dataField : "mng_org_name",
					width : "55", 
					minWidth : "45",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var ret = value;
						if (value != null && value != "") {
							ret = value;
						}
						return ret;
					},
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
					width : "65", 
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
					minWidth : "110",
					style : "aui-center aui-popup",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "연식", 
					dataField : "made_dt", 
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value.substr(0, 4);
					},
					width : "45", 
					minWidth : "35",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "가동시간", 
					dataField : "op_hour", 
					width : "55", 
					minWidth : "35",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "GPS", 
					dataField : "gps_no",
					headerStyle : "aui-fold",
					width : "100", 
					minWidth : "100",
					style : "aui-center aui-popup",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var ret = value;
						if (item.sar != null && item.sar != "") {
							ret = "SA-R";
						}
						return ret;
					},
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "등록번호", 
					dataField : "mreg_no", 
					width : "90", 
					minWidth : "35",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name",
					width : "65", 
					minWidth : "50", 
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "휴대폰", 
					headerStyle : "aui-fold",
					dataField : "hp_no",
					width : "100", 
					minWidth : "100", 
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "상태", 
					dataField : "rental_status_name", 
					style : "aui-center  aui-popup",
					width : "60", 
					minWidth : "50", 
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (item.aui_status_cd == "R") {
							return "미회수";
						}
						if (item.out_dt == "") {
							return "출고요청";
						} else {
							if (item.extend_yn == "Y" && item.return_dt == "") {
								return "연장";
							} else {
								if (item.return_dt != "") {
									if(item.rental_status_cd == "05") {
										return "종결";
									}
									return "미정산";
								} 
								return "출고";								
							}
						}
					},
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "접수자", 
					headerStyle : "aui-fold",
					dataField : "receipt_mem_name",
					width : "50", 
					minWidth : "50", 
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "렌탈시작",
					headerStyle : "aui-fold",
					dataField : "rental_st_dt",
					dataType : "date",
					width : "63", 
					minWidth : "50", 
					formatString : "yy-mm-dd",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (item.extend_yn != "Y") {
							return $M.dateFormat(value, "yy-MM-dd");
						} 
					},
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "렌탈종료",
					headerStyle : "aui-fold",
					dataField : "rental_ed_dt",
					dataType : "date", 
					width : "63", 
					minWidth : "50", 
					formatString : "yy-mm-dd",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (item.extend_yn != "Y") {
							return $M.dateFormat(value, "yy-MM-dd");
						} 
					},
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "연장회차",
					dataField : "extend_cnt",
					width : "63",
					minWidth : "50",
					style : "aui-center",
					dataType : "numeric",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "렌탈기간", 
					dataField : "day_cnt",
					width : "63", 
					minWidth : "50", 
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value != null && value != "" ? value+"일" : "";
					},
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},				
				{ 
					headerText : "렌탈금액", 
					dataField : "rental_amt",
					width : "70",  
					minWidth : "50", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "출고일", 
					dataField : "out_dt",
					dataType : "date", 
					width : "63",  
					minWidth : "63", 
					formatString : "yy-mm-dd",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "출고자", 
					dataField : "out_mem_name",
					width : "63",  
					minWidth : "50",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},		
				{ 
					headerText : "연장시작", 
					headerStyle : "aui-fold",
					dataField : "rental_st_dt",
					formatString : "yy-mm-dd",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (item.extend_yn == "Y") {
							return $M.dateFormat(value, "yy-MM-dd");
						} 
					},
					width : "63",  
					minWidth : "63", 
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "연장종료", 
					headerStyle : "aui-fold",
					dataField : "rental_ed_dt",
					formatString : "yy-mm-dd",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (item.extend_yn == "Y") {
							return $M.dateFormat(value, "yy-MM-dd");
						} 
					},
					width : "63",  
					minWidth : "63",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},				
				{ 
					headerText : "연장금액", 
					headerStyle : "aui-fold",
					dataField : "rental_amt",
					width : "70", 
					minWidth : "50",
					style : "aui-right",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (item.extend_yn == "Y") {
							return $M.setComma(value);
						} 
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "회수일", 
					dataField : "return_dt",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "63",  
					minWidth : "63",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},	
				{ 
					headerText : "회수자", 
					dataField : "return_mem_name",
					width : "63", 
					minWidth : "50",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},					
				{
					dataField : "last_yn",
					visible : false
				},
				{
					dataField : "extend_yn",
					visible : false
				},
				{
					dataField : "sar",
					visible : false
				},
				{
					dataField : "gps_seq",
					visible : false
				}
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// AUIGrid.setFixedColumnCount(auiGrid, 9);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
			
			// 상세팝업
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				//차대번호셀 선택한 경우 
				if(event.dataField == "body_no") {
					var params = {
						rental_machine_no : event.item.rental_machine_no
					};
					var popupOption = "scrollbars=no, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=500, left=0, top=0";
					$M.goNextPage('/rent/rent0201p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
				
				//GPS셀 선택한 경우
				if(event.dataField == "gps_no") {
					if (event.item.gps_seq != "") {
						/* var params = {
							gps_seq : event.item.gps_seq
						};
						var popupOption = "scrollbars=no, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=700, height=620, left=0, top=0";
						$M.goNextPage('/rent/rent0203p01', $M.toGetParam(params), {popupStatus : popupOption}); */
						window.open('http://s1.u-vis.com');
					}
					if (event.item.sar != "") {
						/* var param = {
							s_machine_doc_no : event.item.sar
						}
						var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=850, height=590, left=0, top=0";
						$M.goNextPage('/serv/serv0507p01', $M.toGetParam(param), {popupStatus : poppupOption}); */
						window.open('https://terra.smartassist.yanmar.com/machine-operation/map');
					}
				}
				
				//상태셀 선택한 겨우
				if(event.dataField == "rental_status_name" ) {
					var params = {
						rental_doc_no : event.item.rental_doc_no
					}
					var popupOption = "scrollbars=no, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=730, left=0, top=0";
					// 출고, 출고요청이면 렌탈출고/회수처리
					// 연장, 회수면이면 렌탈연장/회수처리
					if (event.item.out_dt == "") {
						$M.goNextPage("/rent/rent0102p01", $M.toGetParam(params), {popupStatus : popupOption});
					} else {
						if (event.item.extend_yn == "Y" || event.item.return_dt != "") {
							$M.goNextPage('/rent/rent0102p02', $M.toGetParam(params), {popupStatus : popupOption});
						} else {
							$M.goNextPage('/rent/rent0102p01', $M.toGetParam(params), {popupStatus : popupOption});								
						}
					}

					// [재호] [3차-Q&A 15591] 렌탈 신청 현황과 렌탈출고/회수현황의 버튼을 동일하게 (리뷰. 두개의 페이지를 띄워주기)
					// $M.goNextPage('/rent/rent0101p01', $M.toGetParam(params), {popupStatus : popupOption});
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
			
			// 구해진 칼럼 사이즈를 적용 시킴.
			var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
		    AUIGrid.setColumnSizeList(auiGrid, colSizeList);
			
		}
		
		
		// 검색 시작일자 세팅 현재날짜의 1달 전
		function fnInitDate() {
			/* var now = "${inputParam.s_current_dt}";
			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -6)); */
			//goSearch();
		}
		
		// 검색 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_body_no", "s_cust_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		function fnMyExecFuncName(data) {
	        goSearch();
	    }
		
		function fnMyExecModelFuncName(data) {
			$M.setValue("s_machine_plant_seq", data.machine_plant_seq);
	        goSearch();
		}
		
		function fnDownloadExcel() {
			var exportProps = {};
			fnExportExcel(auiGrid, "렌탈출고/회수현황", exportProps);
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
							<col width="180px">							
							<col width="50px">
							<col width="90px">
							<col width="45px">
							<col width="90px">	
							<col width="50px">
							<col width="70px">	
							<col width="50px">
							<col width="80px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<td>
									<select class="form-control" id="s_date_type" name="s_date_type">
										<option value="OUT">출고일자</option>
										<option value="RETURN">회수일자</option>
									</select>
								</td>
								<td>
									<div class="form-row inline-pd" style="max-width: 280px;">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" alt="시작일자" value="">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" value="" alt="종료일자">
											</div>
										</div>
										<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
				                     		<jsp:param name="st_field_name" value="s_start_dt"/>
				                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
				                     		<jsp:param name="click_exec_yn" value="Y"/>
				                     		<jsp:param name="exec_func_name" value="goSearch();"/>
				                     	</jsp:include>	
									</div>
								</td>
								<th>메이커</th>
								<td>
									<select id="s_maker_cd" name="s_maker_cd" class="form-control">
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['MAKER']}" var="item">
											<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
												<option value="${item.code_value}" <c:if test="${result.maker_cd == item.code_value}">selected</c:if>>${item.code_name}</option>
											</c:if>
										</c:forEach>
									</select>
								</td>
								<th>모델</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-12">
											<div class="input-group">
												<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
						                     		<jsp:param name="required_field" value="s_machine_name"/>
						                     		<jsp:param name="s_sale_yn" value="N"/>
						                     	</jsp:include>	
											</div>
										</div>
									</div>
								</td>
								<th>관리센터</th>
								<td>
									<select class="form-control width100px" name="s_mng_org_code">
										<option value="">- 전체 -</option>
										<c:forEach items="${orgCenterList}" var="item">
											<option value="${item.org_code}"
											<c:if test="${SecureUser.org_type eq 'CENTER' && SecureUser.org_code eq item.org_code}">selected</c:if>
											>${item.org_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>소유센터</th>
								<td>
									<select class="form-control" name="s_own_org_code">
										<option value="">- 전체 -</option>
										<c:forEach items="${orgCenterList}" var="item">
											<option value="${item.org_code}">${item.org_name}</option>
										</c:forEach>
									</select>
								</td>
							</tr>	
							<tr>
								<th>고객명</th>
								<td>
									<div>
			                     		<input type="text" id="s_cust_name" name="s_cust_name" class="form-control" style="width: 100px; display: inline-block;">
			                     		<span style="display: inline-block; padding-left: 9px;">차대번호</span>
			                     		<input type="text" class="form-control" name="s_body_no" style="width: 100px;display: inline-block;"">
			                     	</div>
								</td>
								<!-- <th></th>
								<td><input type="text" class="form-control" name="s_body_no"></td> -->
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
								<th>상태</th>
								<td>
									<select class="form-control width90px" id="s_rental_status_cd" name="s_rental_status_cd"  style="display: inline-block;">
										<option value="">- 전체 -</option>
										<option value="REQ_OUT">출고요청</option>
										<option value="OUT">출고</option>
										<option value="EXTEND">연장</option>
										<option value="NO_CALC">미정산</option>
										<option value="RECALL">종결</option>
										<option value="NO_RECALL">미회수</option>
									</select>
								</td>									
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;"  onclick="javascript:goSearch()"  >조회</button>
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
							<div class="form-check form-check-inline">
							<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
								<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
								<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
							</c:if>								
								<label for="s_toggle_column" style="color:black;">
									<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
								</label>
							</div>
							<button type="button" class="btn btn-default" onclick="javascript:fnDownloadExcel();"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
						</div>
					</div>
				</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->					
				<div  id="auiGrid"  style="margin-top: 5px; height: 555px;"></div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
					</div>						
					<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
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