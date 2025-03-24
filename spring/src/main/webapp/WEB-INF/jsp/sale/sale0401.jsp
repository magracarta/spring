<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > 장비판매현황-직원별 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-09-21 17:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		
		var auiGrid;
		var yearMonList 	= [];
		var splitParam 		= '<br/> /';
		var fieldPrefix 	= "month";
		var dataFieldName = []; // 펼침 항목(create할때 넣음)
		var isOpen = false;
		var searchList;
		
		$(document).ready(function() {
			fnInit();
			// 그리드 생성
			createAUIGrid();
			goSearch();
		});
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, '장비판매현황_직원별');
		}
		
		
		function fnInit() {
			yearMonList = ${months};
		}
		
		function goSearch() {
		
			var s_month =  $M.getValue("s_month");
			var s_from_month = $M.getValue("s_from_month");
			
			if(s_month.toString().length == 1) {
				s_month = '0' + s_month;
			};
			if(s_from_month.toString().length == 1){
				s_from_month = '0' + s_from_month;
			}
			
			console.log("s_rental_yn : ", $M.getValue("s_rental_yn"));
			
			var param = {
				s_year_mon  		: $M.getValue("s_year") + s_month,
				s_from_year_mon     : $M.getValue("s_from_year") + s_from_month,
				s_rental_yn 		: $M.getValue("s_rental_yn"),
				s_sale_org_code 	: $M.getValue("s_sale_org_code"),
				s_sale_sub_org_code : $M.getValue("s_sale_sub_org_code"),
				s_sale_org_mem 		: $M.getValue("s_sale_org_mem"),
			};
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						yearMonList = result.months;
						dataFieldName = [];
						destroyGrid();
						createAUIGrid();
						AUIGrid.setGridData(auiGrid, result.list);
						searchList = result.list;
					};
				}
			);
		}
	
		
		// 그리드 초기화
		function destroyGrid() {
			AUIGrid.destroy("#auiGrid");
			auiGrid = null;
		}
		
		//그리드생성
		function createAUIGrid() {
			
			// 그리드 데이터필드 저장
			var dataFieldArr = ["total"];
			var dataFieldSize = dataFieldArr.length + yearMonList.length;
			var totalFieldArr = [];
			
			for(var i = 1; i < dataFieldSize; ++i) {
				dataFieldArr.push(fieldPrefix + [i]);
			}
			
			var currYear = yearMonList[0].substr(0, 4);
			
			for(var i = 0; i < yearMonList.length; ++i) {
// 				if(currYear == yearMonList[i].substr(0, 4)) {					
// 					totalFieldArr.push(fieldPrefix + [i+1]);
// 				}
				totalFieldArr.push(fieldPrefix + [i+1]);
			}
			
			console.log("totalFieldArr : ", totalFieldArr);
			
			var gridPros = {
				rowIdField : "_$uid",
				height : 565,
				// fixedColumnCount : 16,
				showRowNumColumn : false,
				useGroupingPanel : false,
				showBranchOnGrouping : false,
				//푸터 상단 고정
				footerPosition : "top",
// 				showFooter : true,
				showFooter : false,
				displayTreeOpen : true,
				enableCellMerge : false,

				// [23426] 총계 틀 고정
				fixedRowCount : 1,
// 				groupingFields : ["maker_group"],
//               	groupingSummary : {
//               		dataFields : dataFieldArr,
//                  	excepts : ["machine_name"],
//               	},


			    // 그룹핑 썸머리행의 앞부분에 값을 채울지 여부
	            // true 설정하면 그룹핑된 행도 세로 병합이 됨.
// 	            fillValueGroupingSummary : true,
	            // fillValueGroupingSummary=true 설정 일 때에만 유효
	            // 썸머리 행의 위치를 일괄 적으로 groupingFields 의 마지막 필드에 위치시킬지 여부
// 	            adjustSummaryPosition : true,
	            // 그룹핑 후 셀 병합 실행
	            enableCellMerge : true,
	            // 브랜치에 해당되는 행을 출력 여부
	            showBranchOnGrouping : false,
	            
	         	// 그리드 ROW 스타일 함수 정의
// 	            rowStyleFunction : function(rowIndex, item) {
// 	                if(item._$isGroupSumField) { // 그룹핑으로 만들어진 합계 필드인지 여부
// 	                   return "aui-grid-row-depth3-style";
// 	                };
// 	            	return null;
// 				}

				rowStyleFunction : function(rowIndex, item) {
					if(item.maker_name.indexOf("합계") != -1 || 
							item.maker_name.indexOf("총계") != -1 || 
							item.machine_name.indexOf("합계") != -1) {
						return "aui-grid-row-depth3-style";
					} 
					return null;
				}
			};
			
			var columnLayout = [
				{
				    headerText: "분류",
					children : [
						{
							headerText : "메이커",
							dataField : "maker_name",
							width : "110",
							minWidth : "85",
							style : "aui-center",
							cellMerge : true,
// 							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
// 								if(item._$isGroupSumField) { // 그룹핑으로 만들어진 합계 필드인지 여부
									
// 							    	var oldFieldName = item._$sumFieldValue;
// 							    	var weightTypeCd = oldFieldName.charAt(oldFieldName.length-1)
// 							    	var newFieldName = "";

// 							    	if(weightTypeCd == "S") {
// 							    		newFieldName = oldFieldName.slice(0,-1) + "소형 합계";
// 							    	} else if(weightTypeCd == "L") {
// 							    		newFieldName = oldFieldName.slice(0,-1) + "대형 합계";
// 							    	} else if(weightTypeCd == "N") {
// 							    		newFieldName = oldFieldName.slice(0,-1) + " 합계";
// 							    	};
							    	
// 							    	return newFieldName;
// 							   	}
// 								var makerName = value.replace(/(L|N|S)/g, "");
// 								return makerName;
// 							},
						}, 
						{
							headerText : "규격 코드", 
							dataField : "maker_weight_type_cd", 
							width : "5%", 
							style : "aui-center",
							visible : false,
						}, 
					]
				},
				{
					headerText : "모델명", 	
					dataField : "machine_name", 
					width : "130",
					minWidth : "85",
// 					style : "aui-left"
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(item.machine_name.indexOf("합계") != -1 ) {
							return "aui-center";
						}
						return "aui-left";
					},					
				},
				{
					headerText : "연계", 
					dataField : "total", 
					width : "65",
					minWidth : "85",
					style : "aui-center",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value > 0) {
							return "aui-popup";
						}
					},
				    expFunction : function(  rowIndex, columnIndex, item, dataField ) {
				    	var sumValue = 0;
				    	var currYear = yearMonList[0].substr(0, 4);
				    	
				    	if(isOpen){
				    		for (var i = 0; i < totalFieldArr.length; ++i) {
				    			sumValue += $M.toNum(item[totalFieldArr[i]]);			    			
					    	}
				    	}else{
				    		for (var i = 0; i < totalFieldArr.length-12; ++i) {
				    			sumValue += $M.toNum(item[totalFieldArr[i]]);			    			
					    	}
				    	}
				    	
				    	return isNaN(sumValue) ? 0 : sumValue;
				    },
				},
				{
					headerText : "st_year_mon",
					dataField : "st_year_mon",
					visible : false,
					expFunction : function(  rowIndex, columnIndex, item, dataField ) {
						var idx = totalFieldArr.length;
						if(!isOpen){
							idx = totalFieldArr.length-12
						}
						var headerText = AUIGrid.getColumnItemByDataField(auiGrid, "month"+idx).headerText;
						return headerText.replace(splitParam, '');
					},
				},
				{
					headerText : "ed_year_mon",
					dataField : "ed_year_mon",
					visible : false,
					expFunction : function(  rowIndex, columnIndex, item, dataField ) {
						var headerText = AUIGrid.getColumnItemByDataField(auiGrid, "month1").headerText;
						return headerText.replace(splitParam, '');
					},
				},
			];
			
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "machine_name",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "total",
					positionField : "total",
					formatString : "#,##0",
					labelFunction : function(value, columnValues, footerValues) {
						var totalSum = 0;
						for(var i =0, len=columnValues.length; i<len; i++) {
							totalSum += columnValues[i];
						}			
						return isNaN(totalSum) ? 0 : totalSum;
					},
					style : "aui-center aui-footer",
				},
			];

			var fieldNum = 0; 
			
			var s_month =  $M.getValue("s_from_month");
			
			if(s_month.toString().length == 1) {
				s_month = '0' + s_month;
			}
			
			var searchDate = $M.getValue("s_from_year") + s_month;

			for (var i = 0; i < yearMonList.length; ++i) {
				fieldNum += 1;
				var fieldName = fieldPrefix + fieldNum;
				var obj = {
					headerText : yearMonList[i].substr(0,4) + splitParam + yearMonList[i].substr(5,2),
					dataField : fieldName,
					width : "4%", 
// 					headerStyle : "aui-fold",
					style : "aui-center",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value == 0) {
							return "aui-grid-row-depth3-style";
						}
						return "aui-popup"
					},
				}
				
				var gridDate = yearMonList[i].substr(0,4) + yearMonList[i].substr(5,2);
				if ($M.dateFormat($M.toDate(searchDate), 'yyyyMM') > gridDate) {
					obj.headerStyle = "aui-fold";
				}
					
				var sumObj = {
					dataField : fieldName,
					positionField : fieldName,
					formatString : "#,##0",
					operation : "SUM",
					style : "aui-center aui-footer",	
				}
				columnLayout.push(obj);
				footerColumnLayout.push(sumObj);
			}
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			
			// 클릭시 팝업 그리드 호출(상세보기)
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField != 'maker_name' && event.dataField != 'machine_name') {
					var eventValue = $M.nvl(event.value, 0);

					if(eventValue == 0) {
						return;
					}

					var year_month = event.headerText.replace(splitParam, '');
					var param = {
						"year_mon" 				: year_month,
						"machine_name" 			: event.item.machine_name,
						"maker_cd" 				: event.item.maker_cd,
						"maker_weight_type" 	: event.item.maker_weight_type,
						"rental_yn" 			: $M.getValue("s_rental_yn"),
						"s_sale_org_code" 		: $M.getValue("s_sale_org_code"),
						"s_sale_sub_org_code"	: $M.getValue("s_sale_sub_org_code"),
						"s_sale_org_mem" 		: $M.getValue("s_sale_org_mem"),
					}
					if (event.item.machine_name.indexOf("합계") != -1 || event.item.maker_name.indexOf("총계")!= -1 || event.item.maker_name.indexOf("합계") != -1) {
						param.machine_name = "";
					}
					if (event.dataField == 'total') {
						param.year_mon = "";
						param.st_year_mon = event.item.st_year_mon;
						param.ed_year_mon = event.item.ed_year_mon;
					}

					var popupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=700, left=0, top=0";
					$M.goNextPage('/sale/sale0401p01', $M.toGetParam(param), {popupStatus : popupOption});
				}
			});
			
			// 펼치기 전에 접힐 컬럼 목록
			var auiColList = AUIGrid.getColumnInfoList(auiGrid);
			console.log(auiColList);
			for (var i = 0; i <auiColList.length; ++i) {
				if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
					dataFieldName.push(auiColList[i].dataField);
				}
			}
			
			if($("input:checkbox[id='s_toggle_column']").is(":checked") == false){
				for (var i = 0; i < dataFieldName.length; ++i) {
					var dataField = dataFieldName[i];
					AUIGrid.hideColumnByDataField(auiGrid, dataField);
				}
			}
		}
		
		function  goSearchSaleOrg(obj) {	
			//영업부서 초기화및 영업 SUB부서 정보 세팅
			
			if(obj.value != "") {
					
				$M.goNextPageAjax(this_page + "/searchSaleOrg" + "/" +  obj.value,"", {method : "get", loader: false},
					function(result) {
								
			    		if(result.success) {
			    				    		
			    			$("select#s_sale_sub_org_code option").remove();	    				
			    			$('#s_sale_sub_org_code').append('<option value="" >'+ "- 전체 -" +'</option>');	
			    			
			    		 	var saleOrgCode = $M.getValue('s_sale_org_code');
			    		 	
			    			//  선택부서가 농기,OR 건기인 경우 영업 SUB 부서 설정 
			    			if ( result.list != ""  && result.list != undefined && ( saleOrgCode == '4100'  || saleOrgCode == '4500' )) {
		    	    			for(i = 0; i< result.list.length; i++){       		    				
		    		    			var optVal = result.list[i].org_code;
		    		    			var optText = result.list[i].org_kor_name;
		    		    			$('#s_sale_sub_org_code').append('<option value="'+ optVal +'">'+ optText +'</option>');			    			
		    	                }	
			    			}  
			    			
			    			// 선택부서가 영업부인경우  영업부와 센터영업부 직원 가져오기
			    			if ( result.list != ""  && result.list != undefined && ( saleOrgCode == '4000' )) {
			    				goSearchSaleOrgMem(saleOrgCode);
			    			}
			    			else {
			    				//3뎁스  초기화
				    			$("select#s_sale_org_mem option").remove();	    	   			
				    			$('#s_sale_org_mem').append('<option value="" >'+ "- 전체 -" +'</option>');	
			    			}			
						}

					}
				);		
			}
			else {
    			//2뎁스 초기화
    			$("select#s_sale_sub_org_code option").remove();
    			$('#s_sale_sub_org_code').append('<option value="" >'+ "- 전체 -" +'</option>');	
    			//3뎁스 초기화
    			$("select#s_sale_org_mem option").remove();	  
    			$('#s_sale_org_mem').append('<option value="" >'+ "- 전체 -" +'</option>');	
			}
			goSearch();
		}
		
		function  goSearchSaleOrgMem(obj) {	
					
		  	// console.log($('#s_sale_org_code').val());
		  		
		  	if(obj.value!=""){

				//영업 SUB부서 초기화및 담당자세팅
				$M.goNextPageAjax(this_page + "/searchSaleOrgMem" + "/" + $('#s_sale_org_code').val()+ "/" + obj.value , "", {method : "get", loader: false},
					function(result) {
						$("select#s_sale_org_mem option").remove();	
						
			 			$('#s_sale_org_mem').append('<option value="" >'+ "- 전체 -" +'</option>');	
		
		    			if ( result.list != "" && result.list != undefined ) {
		    			
			    			for(i = 0; i< result.list.length; i++){       		    				
				    			var optVal = result.list[i].mem_no;
				    			var optText = result.list[i].kor_name;
				    			$('#s_sale_org_mem').append('<option value="'+ optVal +'">'+ optText +'</option>');			    			
			                }	
		    			
		    			}
					}
				);			
		  	}
		  	else {
				//3뎁스 초기화
				$("select#s_sale_org_mem option").remove();	  
				$('#s_sale_org_mem').append('<option value="" >'+ "- 전체 -" +'</option>');	
		  	}
		  	goSearch();
		}
		
		// 펼침
		function fnChangeColumn(event) {
			var data = AUIGrid.getGridData(auiGrid);
			var target = event.target || event.srcElement;
			if(!target)	return;

			var dataField = target.value;
			var checked = target.checked;
			isOpen = checked;
			
			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGrid, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGrid, dataField);
				}
			}
			AUIGrid.setGridData(auiGrid, searchList);
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
	<!-- 					<h2>장비판매현황-직원별</h2> -->
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
	<!-- /메인 타이틀 -->
					<div class="contents">
	<!-- 기본 -->					
						<div class="search-wrap">
							<table class="table">
								<colgroup>
									<col width="60px">
									<col width="280px">
									<col width="50px">
									<col width="400px">
									<col width="95px">
									<col width="*">
								</colgroup>
								<tbody>
									<tr>								
										<th>조회년월</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-auto">
													<select class="form-control width120px" name="s_from_year" id="s_from_year">
															<c:forEach var="i" begin="2007" end="${inputParam.s_current_year}" step="1">
																<option value="${i}" <c:if test="${i eq fn:substring(s_from_year, 0, 4)}">selected="selected"</c:if>>${i}년</option>
															</c:forEach>
													</select>
												</div>
												<div class="col-auto">
													<select class="form-control width120px" name="s_from_month" id="s_from_month">
															<c:forEach var="i" begin="01" end="12" step="1">
																<option value="${i}" <c:if test="${i eq fn:substring(s_from_year, 5, 7)}">selected="selected"</c:if>>${i}월</option>
															</c:forEach>
													</select>
												</div>
												<div class="col-auto">~</div>
												<div class="col-auto">
													<select class="form-control width120px" name="s_year" id="s_year">
															<c:forEach var="i" begin="2007" end="${inputParam.s_current_year}" step="1">
																<option value="${i}" <c:if test="${i eq inputParam.s_current_year}">selected="selected"</c:if>>${i}년</option>
															</c:forEach>
													</select>
												</div>
												<div class="col-auto">
													<select class="form-control width120px" name="s_month" id="s_month">
															<c:forEach var="i" begin="01" end="12" step="1">
																<option value="${i}" <c:if test="${i eq fn:substring(inputParam.s_current_mon, 4, 6)}">selected="selected"</c:if>>${i}월</option>
															</c:forEach>
													</select>
												</div>
											</div>
										</td>	
										<th>부문</th>
	<!-- 셀렉트박스 3개일 경우		-->
										<td>
											<div class="form-row inline-pd">
												<div class="col-4">
													<select class="form-control" id="s_sale_org_code" name="s_sale_org_code"  onchange="javascript:goSearchSaleOrg(this);">																												
													<option value="">- 전체 -</option>
														<c:forEach items="${orgList}" var="item">
															<c:if test="${item.org_code eq '4000' }"> 																
																<option value="${item.org_code}"> ${item.org_name}</option>
															</c:if>
															<c:if test="${item.org_code eq '4100' }"> 
																<option value="${item.org_code}"> ${item.org_name}</option>
															</c:if>
															<c:if test="${item.org_code eq '4500' }"> 															
																<option value="${item.org_code}"> ${item.org_name}</option>
															</c:if>
														</c:forEach>
													</select>
												</div>
												<div class="col-4">
													<select class="form-control" id="s_sale_sub_org_code" name="s_sale_sub_org_code" onchange="javascript:goSearchSaleOrgMem(this);">
														<option value="">- 전체 -</option>
													</select>
												</div>
												<div class="col-4">
													<select class="form-control" id="s_sale_org_mem" name="s_sale_org_mem" onchange="goSearch();">
														<option value="">- 전체 -</option>
													</select>
												</div>
											</div>
										</td>
	<!-- /셀렉트박스 3개일 경우 -->	
	<!-- 셀렉트박스 4개일 경우								
										<td>
											<div class="form-row inline-pd">
												<div class="col-3">
													<select class="form-control">
														<option>전체</option>
														<option>전체</option>
														<option>전체</option>
													</select>
												</div>
												<div class="col-3">
													<select class="form-control">
														<option>전체</option>
														<option>전체</option>
														<option>전체</option>
													</select>
												</div>
												<div class="col-3">
													<select class="form-control">
														<option>전체</option>
													</select>
												</div>
												<div class="col-3">
													<select class="form-control">
														<option>전체</option>
													</select>
												</div>
											</div>
										</td>
	<!-- /셀렉트박스 4개일 경우 -->	
	
										<td class="pl15">
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="checkbox" id="s_rental_yn" name="s_rental_yn" value="Y" checked="checked" onclick="goSearch()">
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
	
						<div id="auiGrid" style="margin-top: 5px;"></div>
	
	<!-- 그리드 서머리, 컨트롤 영역 -->
						<div class="btn-group mt5">
							<div class="left">
								총 <strong class="text-primary" id="total_cnt">0</strong>건
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